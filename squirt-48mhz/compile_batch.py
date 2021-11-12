import shutil
import os

console = "wb";
for num in range(50, 150, 5):
    print("Editing post_proc.vhd: " + str(num))
    f = open("post_proc.vhd", 'r+')
    f.seek(0x230)
    f.write(str(num).zfill(3))
    f.close()
    print("Compiling: " + str(num))
    os.system("assemble.bat")
    print("Copying " + str(num))
    namex = "Batch/XSVF/rgh12_" + console + "_" + str(num) + "_v2.xsvf"
    names = "Batch/SVF/rgh12_" + console + "_" + str(num) + "_v2.svf"
    shutil.copyfile("overall.xsvf", namex)
    shutil.copyfile("overall.svf", names)