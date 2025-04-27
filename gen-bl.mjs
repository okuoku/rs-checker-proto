import {readFile, readdir, writeFile} from "fs/promises";

const dir = "out";

async function run(){
    const dirl = await readdir(dir);
    const files = dirl
        .filter(e => e.startsWith("binlog-"))
        .map(e => dir + "/" + e);

    var global_targets = [];

    function pathenc(str){
        return str.replace(/\\/g, "/");
    }

    for(const idx in files){
        console.log(files[idx]);
        const obj = JSON.parse(await readFile(files[idx], "utf-8"));
        for(const i in obj){
            const ent = obj[i];
            if(ent.o){
                if(ent.o.BuiltProjectOutputGroupKeyOutput){
                    const out = ent.o.BuiltProjectOutputGroupKeyOutput;
                    const me = {
                        proj: pathenc(ent.proj),
                        item: pathenc(out.ItemSpec)
                    };
                    global_targets.push(me);
                }
            }
        }
    }

    await writeFile("bl.json", JSON.stringify(global_targets, null, 2));
}

run();
