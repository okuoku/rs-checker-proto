import {readFile, writeFile} from "fs/promises";

async function run(infile, outfile){
    const ast_text = await readFile(infile);
    const ast = JSON.parse(ast_text);

    let funcs = {};

    function curbox(init){
        let box = init;
        return function(x){
            if(x === true){
                return box;
            }else{
                box = x;
            }
        }
    }

    function pick(node, box){
        let loc = false;
        let line = false;
        let curfile = box(true);
        /* Pickup location */
        if(node.loc){
            if(node.loc.presumedFile){
                curfile = node.loc.presumedFile;
                box(curfile);
                //console.log("P curfile", curfile);
            }else if(node.loc.file){
                curfile = node.loc.file;
                box(curfile);
                //console.log("R curfile", curfile);
            }
            if(node.loc.presumedLine){
                line = node.loc.presumedLine;
            }else if(node.loc.line){
                line = node.loc.line;
            }
        }

        if(node.kind === "FunctionDecl"){
            const name = node.mangledName;
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

            loc = curfile;
            line = node.line;
            if(! loc){
                console.log("MISSING", name);
            }

            funcs[name] = loc + (line ? "\t" + line.toString() : "");
        }

        if(node.inner){
            const nbox = curbox(curfile);
            node.inner.forEach(e => pick(e, nbox));
        }
    }

    pick(ast, curbox("UNKNOWN"));

    let out = "";
    for(const name in funcs){
        out += name + "\t" + funcs[name] + "\n";
    }

    await writeFile(outfile, out);
}

const infile = process.argv[2];
const outfile = process.argv[3];

run(infile, outfile);


