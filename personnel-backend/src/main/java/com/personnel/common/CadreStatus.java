package com.personnel.common;

/**
 * 干部在库状态常量（与 cadre_info.cadre_status 约定一致）
 */
public final class CadreStatus {

    /** 在职 */
    public static final String ON_JOB = "ON_JOB";

    /** 离退休 */
    public static final String RETIRED = "RETIRED";

    /** 已调出 */
    public static final String TRANSFERRED = "TRANSFERRED";

    /** 已辞职/辞退 */
    public static final String RESIGNED = "RESIGNED";

    private CadreStatus() {
    }
}
