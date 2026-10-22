const fs=require('fs'),path=require('path');
const {load,pix}=require('./png-tools.cjs');
const root=path.resolve(__dirname,'../../../..'),out=path.resolve(__dirname,'..');
const v=JSON.parse(fs.readFileSync(path.join(out,'validation.json'))),checks=[];
function check(name,value,detail){checks.push({name,passed:!!value,detail});}
for(const [n,w,h] of [['speech_paper.png',768,256],['speech_paper_tail.png',96,96],['speech_chevron.png',64,64]]){
 const p=path.join(root,'godot/assets/ui/moon_runes/common',n),b=fs.readFileSync(p),im=load(p);check(n+' dimensions / RGBA8',im.w===w&&im.h===h&&b[24]===8&&b[25]===6,[im.w,im.h,b[24],b[25]]);
 let alphaEdge=0,dirtyZero=0;for(let y=0;y<h;y++)for(let x=0;x<w;x++){let p=pix(im,x,y);if((y===0||y===h-1||x===0||(x===w-1&&n!=='speech_paper_tail.png'))&&p[3])alphaEdge++;if(!p[3]&&p.slice(0,3).some(v=>v))dirtyZero++;}
 check(n+' exterior transparent',alphaEdge===0,alphaEdge);check(n+' zero-alpha RGB clean',dirtyZero===0,dirtyZero);
 if(n==='speech_paper.png'){
  let count=0,s=[0,0,0],ss=[0,0,0],notOpaque=0,maxJump=0;
  for(let y=40;y<216;y++)for(let x=40;x<728;x++){let p=pix(im,x,y);count++;if(p[3]!==255)notOpaque++;for(let k=0;k<3;k++){s[k]+=p[k];ss[k]+=p[k]*p[k];}if(x>40)maxJump=Math.max(maxJump,Math.abs(p[0]-pix(im,x-1,y)[0]));}
  const mean=s.map(a=>a/count),std=ss.map((a,k)=>Math.sqrt(a/count-mean[k]*mean[k]));check('central 688x176 fully opaque',notOpaque===0,notOpaque);check('quiet central paper / no large stains',std.every(x=>x<4),{mean:mean.map(x=>+x.toFixed(2)),std:std.map(x=>+x.toFixed(2)),maximum_red_neighbor_delta:maxJump});
 }
 if(n==='speech_paper_tail.png'){let dark=0,paper=0;for(let y=0;y<h;y++)for(let x=60;x<w;x++){const p=pix(im,x,y);if(p[3]>0){paper++;if(p[0]<150||p[1]<120||p[2]<90)dark++;}}check('tail x60..95 open paper overlap / no ink',dark===0,{visible:paper,dark});}
}
v.checks=checks;v.all_automated_checks_passed=checks.every(c=>c.passed);v.visual_review=['reference crop / same-size assembly','blank text area / original chevron silhouette','tail ink join at 3x','actual nearby snowy background composite','40px nine-slice stretched to 1536x384'];fs.writeFileSync(path.join(out,'validation.json'),JSON.stringify(v,null,2));console.log(JSON.stringify(v,null,2));process.exit(v.all_automated_checks_passed?0:1);
