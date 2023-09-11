"""Adds relative path to file which contains current task to output."""
import pathlib

from ansible import constants as C
from ansible.plugins.callback.default import CallbackModule as DefaultCallbackModule


class CallbackModule(DefaultCallbackModule):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'breadcrumber'

    def _print_task_banner(self, task):
        # From ansible/plugins/callback/default.py
        args = ''
        if not task.no_log and C.DISPLAY_ARGS_TO_STDOUT:
            args = u', '.join(u'%s=%s' % a for a in task.args.items())
            args = u' %s' % args

        prefix = self._task_type_cache.get(task._uuid, 'TASK')

        # Use cached task name
        task_name = self._last_task_name
        if task_name is None:
            task_name = task.get_name().strip()

        # Add relative path to task to output
        task_path = pathlib.Path(task.get_path()).relative_to(pathlib.Path.cwd())
        task_name += f' ({task_path})'

        if task.check_mode and self.get_option('check_mode_markers'):
            checkmsg = " [CHECK MODE]"
        else:
            checkmsg = ""
        self._display.banner(u"%s [%s%s]%s" % (prefix, task_name, args, checkmsg))

        if self._display.verbosity >= 2:
            self._print_task_path(task)

        self._last_task_banner = task._uuid
