import {readFile, writeFile} from "fs/promises";

/* Encode binary into text and remove whitespaces */

function search_lf(bin, start){
    const len = bin.length;
    // FIXME: just use indexOf
    for(let i = start; i != len; i++){
        if(bin[i] == 0x0a){
            return i;
        }
    }
    return -1;
}

function compress_to_text(bin){
    const orig_size = bin.length;
    if(bin.length < 1024*1024*100){
        /* short circuit */
        return bin.toString("utf8");
    }else{
        let c = 0;
        let i = 0;
        let r = "";
        i = search_lf(bin, c);
        while(i >= 0){
            const s = bin.toString("utf8", c, i).trim();
            r += s;
            c = i+1;
            if(c == orig_size){
                break;
            }
            i = search_lf(bin, c);
        }
        r += bin.toString("utf8", c);
        const new_size = r.length;
        return r;
    }
}

async function run(infile, outfile){
    const ast_text = await readFile(infile);
    const ast = JSON.parse(compress_to_text(ast_text));

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


