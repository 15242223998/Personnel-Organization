import re, os, sys
d = r'C:\Users\Administrator\Desktop\Git-Project\Personnel-Organization-Project\docs'
for f in ['项目-架构图.svg','项目-模块调用链路图.svg','项目-领域实体关系图.svg','ER实体图.svg']:
    p = os.path.join(d, f)
    s = open(p, encoding='utf-8').read()
    texts = re.findall(r'>([^<>]+)</text>', s)
    texts += re.findall(r'>([^<>]+)</tspan>', s)
    seen=[]
    for t in texts:
        t=t.strip()
        if t and t not in seen:
            seen.append(t)
    print('='*30, f, 'len=', len(s))
    print(' | '.join(seen)[:2500])
    print()
