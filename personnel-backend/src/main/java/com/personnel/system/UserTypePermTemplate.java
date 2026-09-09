package com.personnel.system;

/**
 * 用户类型内置默认权限模板（全系统唯一口径）。
 *
 * <p>权限收敛决策：sys_role / sys_user_role 不再作为生效权限来源（表与种子留库但不再被读取），
 * 生效权限 effective(user) 只按以下顺序计算：</p>
 * <ol>
 *   <li>userType=1（系统管理员）→ "ALL"；</li>
 *   <li>用户级 sys_user.permissions 非空 → 取该用户级覆盖（逗号串）；</li>
 *   <li>否则 → 按 userType 取本常量类内置默认模板。</li>
 * </ol>
 *
 * <p>模板中的模块 key 与系统 10 个功能模块 key 对齐（与前端 src/utils/perms.js PERM_KEYS 一致）：
 * organization=组织机构管理、cadre=干部信息管理、transfer=干部调配管理、promotion=职级晋升管理、
 * appointment=干部任免管理、evaluation=干部考察评价管理、supervision=干部监督管理、
 * assessment=干部考核管理、daily=日常事务管理、system=系统管理。</p>
 *
 * <p>userType 取值：1系统管理员 / 2校级领导 / 3组织部部长 / 4组织员 / 5二级学院领导 / 6普通干部；
 * 低于 1 或大于 6 视为非法。</p>
 */
public final class UserTypePermTemplate {

    private UserTypePermTemplate() {
    }

    /** 全部模块通配标记（系统管理员 userType=1 生效值） */
    public static final String ALL = "ALL";

    // ---------- 10 个模块 key（与 PERM_KEYS 对齐，供模板拼接与代码引用） ----------
    public static final String KEY_ORGANIZATION = "organization";
    public static final String KEY_CADRE = "cadre";
    public static final String KEY_TRANSFER = "transfer";
    public static final String KEY_PROMOTION = "promotion";
    public static final String KEY_APPOINTMENT = "appointment";
    public static final String KEY_EVALUATION = "evaluation";
    public static final String KEY_SUPERVISION = "supervision";
    public static final String KEY_ASSESSMENT = "assessment";
    public static final String KEY_DAILY = "daily";
    public static final String KEY_SYSTEM = "system";

    /** type2 校级领导 / type3 组织部部长 / type4 组织员：除 system 外全部 9 个业务模块 */
    public static final String TYPE_2_3_4_TEMPLATE = join(
            KEY_ORGANIZATION, KEY_CADRE, KEY_TRANSFER, KEY_PROMOTION, KEY_APPOINTMENT,
            KEY_EVALUATION, KEY_SUPERVISION, KEY_ASSESSMENT, KEY_DAILY);

    /** type5 二级学院领导：机构/干部/调配/晋升/考核/日常 */
    public static final String TYPE_5_TEMPLATE = join(
            KEY_ORGANIZATION, KEY_CADRE, KEY_TRANSFER, KEY_PROMOTION, KEY_ASSESSMENT, KEY_DAILY);

    /** type6 普通干部：空（默认无模块权限，需管理员按用户单独授权） */
    public static final String TYPE_6_TEMPLATE = "";

    /**
     * 按用户类型返回其内置默认权限（逗号串，可为空串）。
     *
     * @param userType 1~6；null 或越界返回 null（视为非法类型，调用方应回退为空）
     */
    public static String templateOf(Integer userType) {
        if (userType == null) {
            return null;
        }
        return switch (userType) {
            case 1 -> ALL;
            case 2, 3, 4 -> TYPE_2_3_4_TEMPLATE;
            case 5 -> TYPE_5_TEMPLATE;
            case 6 -> TYPE_6_TEMPLATE;
            default -> null;
        };
    }

    private static String join(String... keys) {
        return String.join(",", keys);
    }
}
