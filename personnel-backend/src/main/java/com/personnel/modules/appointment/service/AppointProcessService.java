package com.personnel.modules.appointment.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.personnel.modules.appointment.entity.AppointProcess;

public interface AppointProcessService extends IService<AppointProcess> {

    AppointProcess getFullProcess(Long id);
}
