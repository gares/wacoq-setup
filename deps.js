#!/usr/bin/env node

import path from 'path';
import chld from 'child-process-promise';


const prefix = process.env['OPAM_SWITCH_PREFIX'];


async function getDeps(pkg) {
    try {
    var p = await chld.spawn('ocamlfind', ['query', pkg, '-r', '-format', '%+m %+a',
        '-predicates', 'byte'], {stdio: ['ignore', 'pipe', 'inherit'], capture: ['stdout']});
    }
    catch (e) {
        console.error("error running ocamfind");
        return;
    }

    let filenames = p.stdout.toString().split(/[\s\n]+/).filter(x => x);

    filenames = filenames.map(fn => path.relative(prefix, fn));
    console.log(filenames);

    return filenames;
}

async function createZip(dir, filenames) {
    await chld.spawn('zip', ['/tmp/a.zip', ...filenames],
                     {stdio: 'inherit', cwd: dir});
}


(async () => {
    await createZip(prefix, await getDeps('elpi'));
})();