package com.personnel.modules.assessment.service;

import com.personnel.modules.assessment.dto.BallotSubmitDTO;
import com.personnel.modules.assessment.vo.BallotResultItemVO;
import com.personnel.modules.assessment.vo.SignatureVO;
import com.personnel.modules.assessment.vo.TabletSchemeDetailVO;
import com.personnel.modules.assessment.vo.TabletSchemeListVO;

import java.util.List;

/**
 * 平板评审投票服务：进行中方案列表/详情、表决式投票、签字留证
 */
public interface TabletVoteService {

    /** 平板端进行中方案列表（含本人签字状态与投票进度） */
    List<TabletSchemeListVO> listOngoingSchemes(Long voterId);

    /** 平板端方案详情（本人已投状态 + 测评对象 + 维度指标） */
    TabletSchemeDetailVO getSchemeDetail(Long schemeId, Long voterId);

    /** 表决式投票（覆盖式提交，签字后不可修改） */
    void submitBallot(BallotSubmitDTO dto, Long voterId);

    /** 签字留证：校验完整性后保存签字图片与MD5 */
    void sign(Long schemeId, Long voterId, String signImage, String deviceIp);

    /** 方案签字留证列表 */
    List<SignatureVO> listSignatures(Long schemeId);

    /** 表决结果计票 */
    List<BallotResultItemVO> countBallotResult(Long schemeId);
}
