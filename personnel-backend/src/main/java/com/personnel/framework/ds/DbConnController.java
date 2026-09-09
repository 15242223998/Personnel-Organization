package com.personnel.framework.ds;

import com.personnel.common.BusinessException;
import com.personnel.common.Result;
import com.personnel.framework.security.LoginUser;
import com.personnel.framework.security.SecurityUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.annotation.Resource;
import java.util.Objects;

/**
 * 登录页"数据库热切换"接口。
 *
 * <ul>
 *   <li>GET  /api/db/current —— 当前主数据源名与库；</li>
 *   <li>POST /api/db/probe   —— 结构探测（连通性/库存在/差异清单）；</li>
 *   <li>POST /api/db/align   —— 数据对齐（仅全新/空库执行 init.sql，防误清；需系统管理员）；</li>
 *   <li>POST /api/db/switch  —— 运行时切换到目标库（需系统管理员）。</li>
 * </ul>
 *
 * <p>align/switch 属破坏性/变更性操作，强制校验当前登录用户 userType==1（系统管理员），
 * 否则返回 401（未登录）/403（非管理员）。probe/current 为只读探测，登录页未登录即可使用。</p>
 */
@RestController
@RequestMapping("/api/db")
public class DbConnController {

    @Resource
    private DbAlignService dbAlignService;

    @GetMapping("/current")
    public Result<DbCurrentVO> current() {
        return Result.success(dbAlignService.current());
    }

    @PostMapping("/probe")
    public Result<DbProbeVO> probe(@RequestBody DbConnDTO dto) {
        return Result.success(dbAlignService.probe(dto));
    }

    @PostMapping("/align")
    public Result<DbAlignVO> align(@RequestBody DbConnDTO dto) {
        requireAdmin();
        return Result.success(dbAlignService.align(dto));
    }

    @PostMapping("/switch")
    public Result<DbCurrentVO> doSwitch(@RequestBody DbConnDTO dto) {
        requireAdmin();
        return Result.success(dbAlignService.switchTo(dto));
    }

    /** 写接口鉴权：当前登录用户必须是系统管理员(userType==1) */
    private void requireAdmin() {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser == null || loginUser.getUser() == null) {
            throw new BusinessException(401, "未登录或登录已过期，请先以系统管理员账号登录后再执行");
        }
        Integer userType = loginUser.getUser().getUserType();
        if (userType == null || !Objects.equals(userType, 1)) {
            throw new BusinessException(403, "仅系统管理员可执行数据库对齐/切换操作");
        }
    }
}
