import "io" as io
import "__pkg-temp" as pkg
import "grace-pkg" as pm

print (io.listdir("./"));
print ("setup piped")
print ("New package name = {pkg.name}")

if (pkg.__bundle) then {
    pm.bundle(pkg.__loc,pkg.name)
    var cmd := "tar -cvzf {pkg.__loc}../{pkg.name}.tar.gz {pkg.__loc}../{pkg.name}"
    print(cmd)
    io.system(cmd)
}

