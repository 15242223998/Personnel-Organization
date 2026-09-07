package com.personnel.modules.assessment.dto;

import lombok.Data;

import java.util.List;

/**
 * 表决式投票提交 DTO（按 scheme+voter 覆盖式提交）
 */
@Data
public class BallotSubmitDTO {

    private Long schemeId;

    /** 各测评对象的表决意见 */
    private List<BallotChoiceDTO> choices;

    @Data
    public static class BallotChoiceDTO {
        private Long targetCadreId;

        /** APPROVE赞成/DISAPPROVE反对/ABSTAIN弃权 */
        private String choice;
    }
}
