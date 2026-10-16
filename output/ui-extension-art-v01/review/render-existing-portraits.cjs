const {chromium}=require('C:/Users/Loadcomplete/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const path=require('path');const fs=require('fs');const crypto=require('crypto');const {pathToFileURL}=require('url');
(async()=>{
 const root=path.dirname(__dirname);
 const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
 const page=await browser.newPage({deviceScaleFactor:1});
 const checks=[];
 for(const [html,output,width,height] of [
 ['existing-portraits-management.html','01-lodge-management-existing-portraits.png',2172,724],
 ['existing-portraits-dialogue.html','04-map-dialogue-results-existing-portraits.png',1536,1024]]){
  await page.setViewportSize({width,height});
  await page.goto(pathToFileURL(path.join(__dirname,html)).href);
  await page.locator('img').evaluateAll(xs=>Promise.all(xs.map(x=>x.decode())));
  await page.screenshot({path:path.join(root,output)});
  checks.push({html,output,portraits:await page.locator('[data-character]').evaluateAll(xs=>xs.map(x=>({character:x.dataset.character,src:x.getAttribute('src'),filter:getComputedStyle(x).filter}))) });
 }
 const hash=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
 const sourceDir=path.resolve(root,'../../godot/assets/portraits');
 const bindings=fs.readdirSync(path.join(root,'references/portraits')).filter(x=>x.endsWith('.png')).map(file=>({file,source:path.join(sourceDir,file),sha256:hash(path.join(sourceDir,file)),copyMatches:hash(path.join(sourceDir,file))===hash(path.join(root,'references/portraits',file))}));
 fs.writeFileSync(path.join(__dirname,'existing-portrait-verification.json'),JSON.stringify({policy:'Existing game portrait PNG files only. No generation, repainting, recoloring, facial/clothing edits or style transfer. Scale and viewport clipping only.',checks,bindings},null,2));
 console.log(JSON.stringify({renders:checks.length,verifiedOriginalPortraits:bindings.length,allOriginalFilesMatch:bindings.every(x=>x.copyMatches)}));
 await browser.close();if(bindings.some(x=>!x.copyMatches))process.exit(1);
})();
