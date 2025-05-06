import {readFile, writeFile} from "fs/promises";

async function run(infile, outfile){
    const ast_text = await readFile(infile);
    const ast = JSON.parse(ast_text);

    let funcs = {};

    function pick(node, locstack){
        if(node.kind === "FunctionDecl"){
            const name = node.mangledName;
            let loc = false;
            let line = false;
            /* Exclude static / inline */
            if(! name){
                //console.log("Node without mangled name", node.name);
                return;
            }
            if(node.storageClass === "static"){
                return;
            }
            if(node.inline && node.inline === true){
                return;
            }
            /* Exclude implicit */
            if(node.isImplicit){
                return;
            }

            /* Pickup location */
            if(node.range){
                if(node.range.end){
                    if(node.range.end.expansionLoc){
                        loc = node.range.end.expansionLoc.file;
                        line = node.range.end.expansionLoc.line;
                    }
                }

                if(node.range.begin){
                    if(node.range.begin.expansionLoc){
                        loc = node.range.begin.expansionLoc.file;
                        line = node.range.begin.expansionLoc.line;
                    }
                }

                if(! loc){
                    const v = locstack.find(e => e.file);
                    if(v && v.file){
                        loc = v.file;
                        if(node.loc){
                            line = node.loc.presumedLine ? node.loc.presumedLine : node.loc.line;
                        }else{
                            line = v.line;
                        }
                    }else{
                        console.log("MISSING", name);
                    }
                }
            }
            funcs[name] = loc + (line ? "\t" + line.toString() : "");
        }
        if(node.inner){
            let newloc = locstack;
            if(node.loc){
                let myloc = node.loc.expansionLoc ? node.loc.expansionLoc : node.loc;
                if(myloc.presumedFile){
                    myloc.file = myloc.presumedFile;
                }
                if(myloc.presumedLine){
                    myloc.line = myloc.presumedLine;
                }
                newloc = [myloc].concat(locstack);
            }
            node.inner.forEach(e => pick(e, newloc));
        }
    }

    pick(ast, []);

    let out = "";
    for(const name in funcs){
        out += name + "\t" + funcs[name] + "\n";
    }

    await writeFile(outfile, out);
}

const infile = process.argv[2];
const outfile = process.argv[3];

run(infile, outfile);


