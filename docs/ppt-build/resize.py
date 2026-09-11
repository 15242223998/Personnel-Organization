from PIL import Image
import os

src = r'C:\Users\Administrator\Desktop\Git-Project\Personnel-Organization-Project\docs'
dst = r'C:\Users\Administrator\AppData\Local\Doubao\User Data\Default\agent_infra\to\lr_6bf0861ed5e7b8b8'
files = {
    '项目-架构图.png': 'arch_small.png',
    '项目-模块调用链路图.png': 'chain_small.png',
    'ER实体图.png': 'er_small.png',
    '项目-领域实体关系图.png': 'domain_small.png',
}
for cn, en in files.items():
    im = Image.open(os.path.join(src, cn)).convert('RGB')
    w, h = im.size
    scale = min(1.0, 1600 / max(w, h))
    if scale < 1.0:
        im = im.resize((int(w*scale), int(h*scale)), Image.LANCZOS)
    out = os.path.join(dst, en)
    im.save(out, 'PNG')
    print(en, im.size, os.path.getsize(out))
