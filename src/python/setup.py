import importlib
import os
import sys
import subprocess

def get_version():
    version = sys.version.split(" ")[0][:3]
    command_version = ''
    cmd = "python -V"
    p = subprocess.Popen(cmd, shell=True, stderr=subprocess.PIPE)
    defaultVersion = p.stderr.read(10).decode('utf-8')
    if defaultVersion[:-3] == version:
        command_version = ''
    else:
        if float(version) < 3.:
            print('[-] Python version not compatible')
            sys.exit()
        elif 3.6 <= float(version) <= 3.7:
            command_version = version
        else:
            command_version = '3'
    return command_version, version

def import_libs(libs):
    '''
    Example of expected call of the function:

            import_libs(['numpy', 'np'],  ['pandas', 'pd'], ['matplotlib.pyplot', 'plt'], ['requests'])

    Canot use dynamically imported modules in the notebook - imported module does from here not exist in the notebook
          Can't fix the issue
    '''
    exceptions = []
    names = []
    for item in libs:
        name = ""
        if len(item) > 1:
            name = item[1]
            exec("%s = None" % (name))
        else:
            name = item[0]
        try:
            name = importlib.import_module(item[0])
            # name does not exist after import in the notebook
        except ImportError:
            exceptions.append(item[0])
    if len(exceptions) > 0:
        install(exceptions)
    else:
        print("[+] All necessary are present and imported")

def install(libs):
    print("[-] The following libraries are missing")
    for item in libs:
        print(item)
    command_version, version = get_version()
    if command_version != '':
            print('''The python version you are using is different than your default version
            \tdefault verion: %s
            \tyour version: %s
            ''' % (command_version, version))
            print('You need to specify the python versions correpsonding command to install the packeges')
    print('\nThe system will perform the following commands to install the packeges:')
    for item in libs:
        print('python%s -m pip install %s' % (str(command_version), item))
    x = input("\nInstall the packages automatically? Y/n")
    if x != 'n':
        install_libs(libs)
    else:
        return

def install_libs(libs):
    for item in libs:
        try:
            os.system('python%s -m pip install %s' % (str(command_version), item))
        except:
            print("An error occored while installing the package")
            print("check the your 'pip' settings or your python version")
            return
        try:
            importlib.import_module(item)
            print("[+] %s Succeffuly installed" % item)
        except:
            print("An error occored while installing the package")
            print("check the your 'pip' settings or your python version")
            return
    return
