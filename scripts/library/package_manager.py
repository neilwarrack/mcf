import os
import sys
from os.path import join, isdir
from platform import linux_distribution
from collections import defaultdict
import subprocess


PACKAGES = '/home/sergey/.mcf/mcm/packages'
PLATFORM = linux_distribution()[0].lower()
NATIVE_PM = {'arch': 'pacman', 'ubuntu': 'apt'}[PLATFORM]
# PLATFORM = 'ubuntu'


class PackageManager(object):

    def __init__(self):
        pass

    def resolve(self, package_name):
        """
        Resolve package name into a list of commands to install/configure the
        package and its dependencies.
        """
        directory = join(PACKAGES, package_name)
        if isdir(directory):
            return self._resolve_directory(directory, package_name)
        return [(NATIVE_PM, package_name)]

    def resolve_dependencies_file(self, filename):
        commands = list()
        for line in open(filename, 'r'):
            package_name = self._remove_comments(line).strip()
            if len(package_name.split(': ')) == 2:
                commands.append(tuple(package_name.split(': ')))
            elif package_name:
                commands += self.resolve(package_name)
        return commands

    def _resolve_directory(self, directory, package_name):
        commands = list()
        # Check for platform-specific instructions
        platform = join(directory, PLATFORM)
        if os.path.isdir(platform):
            commands += self._resolve_directory(platform, package_name)
        elif os.path.isfile(platform):
            commands += self.resolve_dependencies_file(platform)
        else:
            deps = join(directory, 'DEPENDENCIES')
            script = join(directory, 'install')
            if not os.path.isfile(deps) and not os.path.isfile(script):
                commands.append((NATIVE_PM, package_name))
            else:
                if os.path.isfile(deps):
                    commands += self.resolve_dependencies_file(deps)
                if os.path.isfile(script):
                    commands.append(('script', script))
        # Check for setup script
        setup = join(directory, 'setup')
        if os.path.isfile(setup):
            commands.append(('setup', setup))
        return commands

    def _remove_comments(self, line):
        p = line.find("#")
        if p == -1:
            return line
        return line[:p]

    def _install_with_package_manager(self, manager, package, args=''):
        """
        Install package(s) using given package manager.

        Arguments
        ---------
        manager: str
            Name of a package manager to use (apt, pacman, yaourt, pip).
        package: str | list
            Package name or list of package names.
        args:
            Additional options to pass to the package manager.
        """
        CMD = {'apt': 'sudo apt-get install --force-yes -y',
               'pacman': 'sudo pacman --noconfirm -S',
               'yaourt': 'sudo yaourt --noconfirm -Sa',
               'pip': 'sudo pip install --upgrade'}
        if not manager in CMD.keys():
            raise Exception('Unsupported manager')
        if isinstance(package, list):
            p = package
        elif isinstance(package, set):
            p = list(package)
        else:
            p = [package]
        cmd = CMD[manager] + ' ' + ' '.join(p) + ' ' + args
        subprocess.check_call(cmd.split())

    def _install_with_script(self, script):
        # os.environ['PYTHONPATH'] = '/home/sergey/.mcf/scripts/library'
        subprocess.check_call([script], env=os.environ)

    def install(self, package_name, verbose=False):
        commands = self.resolve(package_name)
        merged = self._merge(commands)
        if verbose:
            self.describe_package(package_name, merged)
        try:
            for pm in ['apt', 'pacman', 'yaourt', 'pip']:
                if pm in merged:
                    print('[*] Install {} packages\n'.format(pm.capitalize()))
                    self._install_with_package_manager(pm, merged[pm])
                    print('')
            if 'script' in merged:
                print('[*] Install scripts\n')
                for s in sorted(merged['script']):
                    print(' -', s)
                    self._install_with_script(s)
                    print('')
            if 'setup' in merged:
                for s in merged['setup']:
                    subprocess.check_call([s], env=os.environ)
        except Exception as e:
            print('Installation of \"{}\" failed'.format(package_name))
            print(e)

    def describe_package(self, package_name, merged):
        print('Package \"{}\" resolved into:\n'.format(package_name))
        for pm in ['apt', 'pacman', 'yaourt', 'pip']:
            if pm in merged:
                print(' - {} packages\n'.format(pm.capitalize()))
                print('  ', ' '.join(merged[pm]))
                print('')
        if 'script' in merged:
            print(' - Custom install scripts\n')
            for s in merged['script']:
                print('  ', s)
            print('')
        if 'setup' in merged:
            print(' - Custom setup scripts\n')
            for s in merged['setup']:
                print('  ', s)
            print('')

    def _merge(self, commands):
        merged = defaultdict(set)
        for c in commands:
            merged[c[0]].add(c[1])
        return dict(merged)


def install(package_name, verbose=False):
    pm = PackageManager()
    pm.install(package_name, verbose)
