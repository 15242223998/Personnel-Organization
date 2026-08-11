package com.personnel.modules.daily.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.daily.entity.DailySelfApplication;

public interface DailySelfApplicationService extends IService<DailySelfApplication> {

    void submit(Long id);

    void approve(Long id, Long approverId, String comment);

    void reject(Long id, Long approverId, String comment);
}
