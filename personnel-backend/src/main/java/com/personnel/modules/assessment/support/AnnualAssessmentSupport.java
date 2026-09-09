package com.personnel.modules.assessment.support;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 年度考核解析与“近三年考核称职以上”统一判定工具（跨模块公共引用：晋升资格、任免启动、后备库核验、档案详情展示）。
 *
 * 考核结果来源：cadre_info.annual_assessment 列，形如 "2024:称职;2025:优秀"
 * （由 assessment_annual 年度考核保存时回写，删除时同步移除）。
 *
 * 【统一判定口径（务必一致）】“近三年考核称职以上”：
 * 取最近三个自然年 W = {T-2, T-1, T}（T = 当前自然年）：
 *   1) 仅统计落在 W 内的年度考核记录；
 *   2) 达标结果等次 ∈ {优秀, 称职, 合格}；W 内任一条记录为
 *      基本称职/不称职/不合格（或其它无法识别的结果）即整体不达标；
 *   3) 关键年份缺失：T-2、T-1 两个“已完成考核的自然年”任一缺记录即为不达标
 *      （缺失原因如 “2024 年度考核记录缺失”）；
 *      当年 T 的考核通常到年末才开展，允许缺位、不判缺失；
 *   4) 综合 2、3 后 W 内达标记录自然满足“至少存在 2 条”
 *      （即 T-2、T-1 均存在且达标），记录不足一律视为不达标；
 *   5) 达标返回空原因数组；不达标返回具体原因（含年度与等次，用于提示/展示）。
 */
public final class AnnualAssessmentSupport {

    /** 达标结果等次（含通用“合格”同义等次） */
    private static final Set<String> PASS_RESULTS = Set.of("优秀", "称职", "合格");

    private AnnualAssessmentSupport() {
    }

    /**
     * 解析 annualAssessment：形如 "2024:称职;2025:优秀"（兼容全角冒号/分号）。
     * 容错：空/null 返回空 Map；行格式错乱（非 4 位年份、缺分隔符、结果为空）整行跳过；
     * 同一年份多条时后者覆盖。
     *
     * @param annualAssessment 干部档案中的考核串
     * @return year(自然年) -> 考核结果(中文)
     */
    public static Map<Integer, String> parse(String annualAssessment) {
        Map<Integer, String> map = new HashMap<>();
        if (annualAssessment == null) {
            return map;
        }
        for (String part : annualAssessment.split("[;；]")) {
            if (part == null) {
                continue;
            }
            String item = part.trim();
            if (item.isEmpty()) {
                continue;
            }
            // 定位分隔符（支持 ':' 与 '：'）
            int sep = -1;
            for (int i = 0; i < item.length(); i++) {
                char ch = item.charAt(i);
                if (ch == ':' || ch == '：') {
                    sep = i;
                    break;
                }
            }
            if (sep <= 0) {
                continue; // 缺年份或分隔符，乱行跳过
            }
            String yearStr = item.substring(0, sep).trim();
            String result = item.substring(sep + 1).trim();
            if (!yearStr.matches("\\d{4}") || result.isEmpty()) {
                continue; // 年份非 4 位数字或结果为空，乱行跳过
            }
            map.put(Integer.parseInt(yearStr), result);
        }
        return map;
    }

    /**
     * 返回“近三年考核称职以上”不达标原因（中文，按年度倒序），达标返回空数组。
     * 原因示例："2025 年度考核结果：基本称职（不达标）"、"2024 年度考核记录缺失"。
     */
    public static List<String> reasons(String annualAssessment) {
        Map<Integer, String> map = parse(annualAssessment);
        int currentYear = LocalDate.now().getYear();
        List<String> reasons = new ArrayList<>();
        // 从 T 到 T-2 逐年度核验：结果不达标 → 记录缺失（当年 T 缺位不判缺失）
        for (int year = currentYear; year >= currentYear - 2; year--) {
            String result = map.get(year);
            if (result == null) {
                if (year < currentYear) {
                    reasons.add(year + " 年度考核记录缺失");
                }
                continue;
            }
            if (!PASS_RESULTS.contains(result)) {
                reasons.add(year + " 年度考核结果：" + result + "（不达标）");
            }
        }
        return reasons;
    }

    /**
     * “近三年考核称职以上”是否达标：空/无记录、记录不足、关键年份缺失、
     * 出现基本称职/不称职/不合格等任一情形均判不达标（口径见类注释）。
     */
    public static boolean qualified(String annualAssessment) {
        return reasons(annualAssessment).isEmpty();
    }
}
