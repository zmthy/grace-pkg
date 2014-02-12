import "io" as io
import "__pkg-temp" as pkg
import "grace-pkg" as pm

print (io.listdir("./"));
print ("setup piped")
print ("New package name = {pkg.name}")

if (pkg.__bundle) then {
    pm.bundle(pkg.__loc,pkg.name)
    var cmd := "tar -cvzf {pkg.__loc}../{pkg.name}.tar.gz {pkg.__loc}/{pkg.name}"
    print(cmd)
    io.system(cmd)
}
else{
    var buildPath := pm.getBuildPath()
    print("Build path = {buildPath}");
    if (!io.exists("{buildPath}/{pkg.name}"))then{
        io.system("mkdir {buildPath}/dist/{pkg.name}")
    }
    print()
    for (pkg.depends) do { dep->
        pm.clearImports();
        pm.fetchImports(dep)
        var imps := pm.getImports()
        for (imps) do { imp->
            pm.write(imp,"{buildPath}/dist/{pkg.name}")
        }
    }

}

