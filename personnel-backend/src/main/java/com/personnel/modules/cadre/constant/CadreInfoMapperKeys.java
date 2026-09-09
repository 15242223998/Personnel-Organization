package com.personnel.modules.cadre.constant;

import com.personnel.modules.cadre.entity.CadreInfo;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 干部档案「信息更正」白名单映射：daily_self_application.apply_field 取值 → cadre_info 实际列名。
 *
 * <p>仅允许白名单内的 key 发起档案更正与审批回写；不在白名单的字段一律拒绝
 * （抛 BusinessException「该字段不支持档案更正」），杜绝前端传任意列名拼接更新。</p>
 *
 * <p>白名单（前端「变更字段」下拉与后端校验共用同一份 key）：</p>
 * <ul>
 *     <li>phone            联系电话        → cadre_info.phone</li>
 *     <li>email            邮箱            → cadre_info.email</li>
 *     <li>education        最高学历        → cadre_info.full_time_education</li>
 *     <li>political_status 政治面貌        → cadre_info.political_status</li>
 *     <li>home_address     家庭住址        → cadre_info.home_address</li>
 *     <li>emergency_contact 紧急联系人     → cadre_info.emergency_contact</li>
 * </ul>
 */
public final class CadreInfoMapperKeys {

    private CadreInfoMapperKeys() {
    }

    /** apply_field key → cadre_info 列名（白名单，仅此清单内的 key 允许回写档案） */
    private static final Map<String, String> KEY_COLUMN = new LinkedHashMap<>();

    /** apply_field key → 中文名称（展示用） */
    private static final Map<String, String> KEY_LABEL = new LinkedHashMap<>();

    static {
        register("phone", "phone", "联系电话");
        register("email", "email", "邮箱");
        register("education", "full_time_education", "最高学历");
        register("political_status", "political_status", "政治面貌");
        register("home_address", "home_address", "家庭住址");
        register("emergency_contact", "emergency_contact", "紧急联系人");
    }

    private static void register(String key, String column, String label) {
        KEY_COLUMN.put(key, column);
        KEY_LABEL.put(key, label);
    }

    /** 是否白名单支持的更正字段 */
    public static boolean supports(String fieldKey) {
        return fieldKey != null && KEY_COLUMN.containsKey(fieldKey);
    }

    /** 返回白名单 key 对应的 cadre_info 列名；不在白名单返回 null */
    public static String columnOf(String fieldKey) {
        return fieldKey == null ? null : KEY_COLUMN.get(fieldKey);
    }

    /** 返回白名单 key 的中文名称；不在白名单返回 null */
    public static String labelOf(String fieldKey) {
        return fieldKey == null ? null : KEY_LABEL.get(fieldKey);
    }

    /** 读取干部档案中该字段 key 的当前值（读真实档案，仅供提交时落 old_value/前端展示） */
    public static String readValue(CadreInfo cadre, String fieldKey) {
        if (cadre == null) {
            return null;
        }
        if ("phone".equals(fieldKey)) {
            return cadre.getPhone();
        }
        if ("email".equals(fieldKey)) {
            return cadre.getEmail();
        }
        if ("education".equals(fieldKey)) {
            return cadre.getFullTimeEducation();
        }
        if ("political_status".equals(fieldKey)) {
            return cadre.getPoliticalStatus();
        }
        if ("home_address".equals(fieldKey)) {
            return cadre.getHomeAddress();
        }
        if ("emergency_contact".equals(fieldKey)) {
            return cadre.getEmergencyContact();
        }
        return null;
    }

    /** 只读白名单副本（校验/展示用） */
    public static Map<String, String> keyLabels() {
        return Collections.unmodifiableMap(KEY_LABEL);
    }
}
