import "io" as io
import "__pkg-temp" as pkg
import "grace-pkg" as pm
import "sys" as sys



print (io.listdir("./"));
print ("setup piped")
print ("New package name = {pkg.name}")

if (pkg.__bundle) then {
    pm.bundle(pkg.__loc,pkg.name)
    print("PACKAGE NAME : = {pkg.name}")
    print("PACKAGE loc : = {pkg.__loc}")
    print("Location = {pkg.__loc}{pm.removeContainingDir(pkg.__loc)}../{pm.removeContainingDir(pkg.__loc)}")
    var cmd := "tar -cvzf {pkg.__loc}../{pkg.name}.tar.gz {pkg.__loc}../{pkg.name}/"
    print(cmd)
    io.system(cmd)
}
else{
    var homePath := sys.environ["HOME"]
    var root := "{homePath}/.lib/{pkg.name}/"
    print ("ROOT = {root}")
    if (pkg.depends.size > 0 )then{
        if (!io.exists("~/.lib/"))then{
            io.system("mkdir ~/.lib/")
        }
    }

    var buildPath := pm.getBuildPath()

    //making sure the name of the extracted folder matches the package name
    var folderName := pm.removeContainingDir(pkg.__loc)

    //check that the exactracted folder exists
    var extractLoc := "~/.lib/{folderName}/"
    print("Exctract loc")
    if (!io.exists(extractLoc))then{
        print("Error extracting to ~/.lib/{folderName}/")
    }
    //ensure that the name is correct
    print("Now moving extraction {extractLoc} to {root}")
    io.system("mv {extractLoc} {root}")
   
   

    io.system("mkdir {root}.lib/")

    //go through dependencies and write them
    for (pkg.depends) do { dep->
        pm.clearImports();
        pm.fetchImports(dep)
        var imps := pm.getImports()
        print("WRITING NOW");
        for (imps) do { imp->
            //pm.write(imp,"{root}")
            writeDirect(imp,"{root}.lib/")
        }
    }

}


method writeDirect(file,location) -> Boolean{
    var toWrite := io.open("{location}{pm.removeContainingDir(file.address)}", "w")
    toWrite.write(file.data)
    toWrite.close
 }
