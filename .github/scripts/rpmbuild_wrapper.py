#!/usr/bin/env python3
import sys
import re
import subprocess

args = sys.argv[1:]
for arg in args:
    if arg.endswith('.spec'):
        try:
            with open(arg, 'r', encoding='utf-8') as f:
                content = f.read()
            # RPM spec Version tag cannot contain hyphens.
            # Convert e.g. "Version: 1.0.0-beta.1+1" -> "Version: 1.0.0"
            cleaned = re.sub(r'Version:\s*([0-9]+\.[0-9]+\.[0-9]+)[^\n]*', r'Version: \1', content)
            with open(arg, 'w', encoding='utf-8') as f:
                f.write(cleaned)
            print(f"[rpmbuild-wrapper] Sanitized Version tag in {arg}")
        except Exception as e:
            print(f"[rpmbuild-wrapper] Warning: could not sanitize {arg}: {e}")

# Forward all arguments to the real rpmbuild executable
sys.exit(subprocess.call(['/usr/bin/rpmbuild.real'] + args))
