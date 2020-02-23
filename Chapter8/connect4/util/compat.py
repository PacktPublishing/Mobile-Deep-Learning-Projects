import sys

if sys.version_info[0] > 2:
    def compat_input(prompt):
        return input(prompt)
else:
    def compat_input(prompt):
        return raw_input(prompt)
