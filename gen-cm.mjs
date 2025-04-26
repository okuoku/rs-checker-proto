import {readFile, readdir} from "fs/promises";

const ctxname = "reposoup";
const dir = "out";
const dirlist = dir + "/cm-projdirs.txt";

async function run(){
    const text = await readFile(dirlist, "utf-8");
    const dirs = text.split(/\r?\n/).filter(e => e !== "");

    const global_targets = {};

    for(const idx in dirs){
        // Search index file
        const dir = dirs[idx];
        const replydir = dir + ".cmake/api/v1/reply";
        const files = await readdir(replydir, {withFileTypes: true});

        const indexEnt = files.find(e => e.name.startsWith("index-"));
        const indexfile = indexEnt ? indexEnt.name : false;
        console.log("dir",dirs[idx],indexfile);

        const index = JSON.parse(await readFile(replydir + "/" + indexfile, "utf-8"));
        const ctx = "client-" + ctxname;
        const replyobj = index.reply[ctx]["query.json"];
        const responses = replyobj.responses;

        let res = {};
        for(const idx in responses){
            res[responses[idx].kind] = responses[idx];
        }

        // Read codemodel
        const codemodelfile = replydir + "/" + res.codemodel.jsonFile;
        const codemodel = JSON.parse(await readFile(codemodelfile, "utf-8"));

        // FIXME: Always use the first configuration
        const targets = codemodel.configurations[0].targets;
        for(const idx in targets){
            const target = targets[idx];
            const targetfile = replydir + "/" + target.jsonFile;
            const targetobj = JSON.parse(await readFile(targetfile, "utf-8"));

            // Ignore targets without artifact
            if(targetobj.artifacts){
                let tgt = {};
                tgt._ref = targetfile;
                tgt._sourceproj = codemodel.paths.source;
                tgt.artifacts = targetobj.artifacts;
                if(targetobj.nameOnDisk){
                    tgt.nameOnDisk = targetobj.nameOnDisk;
                }
                if(targetobj.dependencies){
                    tgt._deps = [];
                    targetobj.dependencies.forEach(e => tgt._deps.push(e.id));
                }
                tgt.type = targetobj.type;
                tgt.name = target.name;

                global_targets[target.id] = tgt;
            }
        }
    }

    console.log(global_targets);
}

run();
