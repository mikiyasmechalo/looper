#!/usr/bin/env python3
import sys
import os
import re
import subprocess

args = sys.argv[1:]
for arg in args:
    if arg.endswith('.spec'):
        try:
            with open(arg, 'r', encoding='utf-8') as f:
                content = f.read()

            # 1. RPM spec Version tag cannot contain hyphens or pluses.
            # Convert e.g. "Version: 1.0.0-beta.2+2" -> "Version: 1.0.0"
            content = re.sub(r'Version:\s*([0-9]+\.[0-9]+\.[0-9]+)[^\n]*', r'Version: \1', content)

            # 2. Defensively ensure all copy commands in %install reference %{_topdir}/BUILD directly
            # so they never fail if rpmbuild creates an isolated build subfolder.
            content = re.sub(
                r'cp -r (?:%\{_builddir\}/)?looper_player/\*',
                r'cp -r %{_topdir}/BUILD/looper_player/*',
                content
            )
            content = re.sub(
                r'cp -r (?:%\{_builddir\}/)?(looper_player\.(?:desktop|png))',
                r'cp -r %{_topdir}/BUILD/\1',
                content
            )
            content = re.sub(
                r'cp -r (?:%\{_builddir\}/)?(looper_player\*\.xml)',
                r'cp -r %{_topdir}/BUILD/\1',
                content
            )

            # 3. Inject a fallback at the start of %install that copies items into the current directory
            # if they are not already there.
            prep_block = (
                "\n# [rpmbuild-wrapper] Fallback copy from %{_topdir}/BUILD if executed in isolated builddir\n"
                "if [ ! -d looper_player ] && [ -d %{_topdir}/BUILD/looper_player ]; then\n"
                "  cp -r %{_topdir}/BUILD/looper_player .\n"
                "fi\n"
                "if [ ! -f looper_player.desktop ] && [ -f %{_topdir}/BUILD/looper_player.desktop ]; then\n"
                "  cp -f %{_topdir}/BUILD/looper_player.* . 2>/dev/null || :\n"
                "fi\n"
            )
            content = re.sub(r'(%install\b[^\n]*)', r'\1' + prep_block, content, count=1)

            with open(arg, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"[rpmbuild-wrapper] Sanitized and patched spec file: {arg}")

            # 4. If any subfolders already exist in BUILD, symlink looper_player into them
            spec_dir = os.path.dirname(os.path.abspath(arg))
            rpmbuild_dir = os.path.dirname(spec_dir)
            build_dir = os.path.join(rpmbuild_dir, 'BUILD')
            if os.path.isdir(build_dir):
                for item in os.listdir(build_dir):
                    item_path = os.path.join(build_dir, item)
                    if os.path.isdir(item_path) and item.endswith('-build'):
                        target_link = os.path.join(item_path, 'looper_player')
                        src = os.path.join(build_dir, 'looper_player')
                        if not os.path.exists(target_link) and os.path.exists(src):
                            try:
                                os.symlink(src, target_link)
                                print(f"[rpmbuild-wrapper] Symlinked {src} -> {target_link}")
                            except Exception as sym_err:
                                print(f"[rpmbuild-wrapper] Symlink error: {sym_err}")
        except Exception as e:
            print(f"[rpmbuild-wrapper] Warning: could not process {arg}: {e}")

# Forward all arguments to the real rpmbuild executable
sys.exit(subprocess.call(['/usr/bin/rpmbuild.real'] + args))
