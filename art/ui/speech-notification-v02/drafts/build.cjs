const fs=require('fs'),path=require('path'),crypto=require('crypto');
const {load,save,make,pix,sample,set,over,resize,crop,nine}=require('./png-tools.cjs');
const root=path.resolve(__dirname,'../../../..'),dir=path.resolve(__dirname,'..'),asset=path.join(root,'godot/assets/ui/moon_runes/common');
const ref=load(path.join(root,'docs/handoff/refs/speech-bubble-concept-crop3x.png'));
const gen=load(path.join(__dirname,'01-imagegen-blank-body.png'));
const protectedPaths=['godot/scripts','godot/scenes','godot/shaders','godot/assets/cards','godot/assets/ui/moon_runes/extension_v01','godot/assets/ui/moon_runes/approved','art/ui/speech-notification-v01','docs','WitchsLodge.exe',...['speech_plain.png','speech_tail_left.png','medal_frame.png'].map(n=>'godot/assets/ui/moon_runes/common/'+n)];
function fingerprints(){let files={};function walk(p){if(!fs.existsSync(path.join(root,p)))return;const st=fs.statSync(path.join(root,p));if(st.isDirectory()){for(let n of fs.readdirSync(path.join(root,p)))walk(p+'/'+n);}else files[p]=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,p))).digest('hex');}for(let p of protectedPaths)walk(p);return files;}
if(!fs.existsSync(path.join(__dirname,'protected-before.json')))fs.writeFileSync(path.join(__dirname,'protected-before.json'),JSON.stringify(fingerprints(),null,2));
if(process.argv.includes('--audit-only')){const before=JSON.parse(fs.readFileSync(path.join(__dirname,'protected-before.json'))),after=fingerprints(),changed=Object.keys(before).filter(k=>before[k]!==after[k]),added=Object.keys(after).filter(k=>!(k in before));const audit={checked_files:Object.keys(before).length,changed,added};fs.writeFileSync(path.join(dir,'protected-audit.json'),JSON.stringify(audit,null,2));console.log(audit);process.exit(changed.length||added.length?1:0);}
if(process.argv.includes('--inspect')){console.log({reference:[ref.w,ref.h],generated:[gen.w,gen.h]});for(let p of [[250,100],[500,100],[500,240],[800,200],[900,230],[140,200],[72,210],[85,90],[500,60],[500,285],[500,304]])console.log(p,pix(ref,...p));process.exit();}
function smooth(a,b,x){x=Math.max(0,Math.min(1,(x-a)/(b-a)));return x*x*(3-2*x);}
function mix(a,b,t){return a.map((v,k)=>v*(1-t)+b[k]*t);}
function paper(x,y){ // Source-matched fine parchment: generated blank edit is the interior input.
 let gx=240+(x/768)*1550,gy=260+(y/256)*220,p=sample(gen,gx,gy);
 let blur=[0,0,0];for(let dx of [-18,0,18])for(let dy of [-18,0,18]){let v=sample(gen,gx+dx,gy+dy);for(let k=0;k<3;k++)blur[k]+=v[k]/9;}
 // Original clean-paper samples cluster around #F6E0B9. Only the edited
 // image's high-frequency pigment grain is kept; no long streaks or stains.
 return [246,224,185].map((v,k)=>v+(p[k]-blur[k])*.9).concat(255);
}
const body=make(768,256);
// The clean right half supplies the hidden left edge as well. Boundaries are read from
// the original ink, not a rectangular mask, so rounded corners have genuine alpha.
let tops=[],bots=[],rights=[];
const dark=(p)=>p[0]<85&&p[1]<65&&p[2]<115;
for(let sx=525;sx<1025;sx++){tops[sx]=null;bots[sx]=null;for(let y=35;y<160;y++)if(dark(pix(ref,sx,y))){tops[sx]=y;break;}for(let y=330;y>200;y--)if(dark(pix(ref,sx,y))){bots[sx]=y;break;}}
for(let sy=25;sy<340;sy++){rights[sy]=null;for(let x=1024;x>=850;x--)if(dark(pix(ref,x,sy))){rights[sy]=x;break;}}
function nearest(a,i){if(a[i]!=null)return a[i];for(let d=1;d<=7;d++){if(a[i-d]!=null)return a[i-d];if(a[i+d]!=null)return a[i+d];}return null;}
for(let y=0;y<256;y++)for(let x=0;x<768;x++){
 let sx=530+Math.abs(x-383.5)*1.245,sy=36+y*290/256;
 let p=sample(ref,sx,sy),top=nearest(tops,Math.round(sx)),bot=nearest(bots,Math.round(sx)),right=nearest(rights,Math.round(sy));
 if(top===null||bot===null||right===null||sx>=1025){continue;}
 let dist=Math.min(sy-top,bot-sy,right-sx),alpha=255;
 if(dist<0){const d=-dist;alpha=255*(1-smooth(0,6,d));p=[103,70,128,alpha];}
 if(dist< -6)alpha=0;
 // Text/arrow removal with smooth transitions, preserving source paper within the border band.
 const edge=Math.min(x,767-x,y,255-y);
 const inside=smooth(23,40,edge);
 let blank=paper(x,y);
 if(sx>958&&sx<978&&sy>169&&sy<201)p=sample(ref,950,sy);
 p=mix(p,blank,inside);p[3]=alpha;
 if(alpha===0||x===0||y===0||x===767||y===255)p=[0,0,0,0];set(body,x,y,p);
}
save(body,path.join(asset,'speech_paper.png'));
// Tail: a thin, source-coloured triangular wedge with an open paper-only overlap.
const tail=make(96,96),ink=[42,25,47,255];
function lineDist(px,py,ax,ay,bx,by){let dx=bx-ax,dy=by-ay,t=Math.max(0,Math.min(1,((px-ax)*dx+(py-ay)*dy)/(dx*dx+dy*dy)));return Math.hypot(px-ax-t*dx,py-ay-t*dy);}
for(let y=0;y<96;y++)for(let x=0;x<96;x++){
 const half=26,tip=9,base=78,dy=Math.abs(y-48),bound=x<base?half*(x-tip)/(base-tip):half;
 if(dy>bound+6||x<tip-6)continue;
 const d=Math.min(lineDist(x,y,tip,48,base,22),lineDist(x,y,tip,48,base,74));
 let p=paper(44+x,100+y*.5);
 p=mix(p,sample(body,32,128+(y-48)),smooth(24,60,x));
 if(x<60){if(dy>bound){p=[103,70,128,100*(1-smooth(0,5,dy-bound))];}else if(d<2.6)p=mix(ink,p,smooth(1.1,2.6,d));}
 else if(dy>bound){continue;}
 if(x>=60){p=sample(body,Math.max(32,x-52),128+(y-48));p[3]=255*(1-smooth(bound-3,bound,dy)*smooth(72,84,x));}
 if(p[3]<1)p=[0,0,0,0];set(tail,x,y,p);
}
save(tail,path.join(asset,'speech_paper_tail.png'));
// The actual reference chevron pixels, not a substitute arrow drawing.
const chevron=make(64,64);
for(let y=0;y<64;y++)for(let x=0;x<64;x++){
 let p=sample(ref,877.5+x,148.5+y),lum=(p[0]+p[1]+p[2])/3;
 let a=255*(1-smooth(70,170,lum));
 if(a<1){set(chevron,x,y,[0,0,0,0]);continue;}
 set(chevron,x,y,[Math.min(p[0],58),Math.min(p[1],39),Math.min(p[2],65),a]);
}
save(chevron,path.join(asset,'speech_chevron.png'));
function assemble(w,h){let a=make(w+52,h),b=nine(body,w,h);over(a,b,52,0);over(a,tail,0,h/2-48);over(a,chevron,w-10-64,h/2-32);return a;}
const match=assemble(958,290);save(match,path.join(__dirname,'02-composite-reference-size.png'));
const stretch=assemble(1536,384);save(stretch,path.join(__dirname,'03-ninepatch-2x-1_5x.png'));
// Contact sheet text is added by label-sheet.ps1 after the pixel comparisons are composed.
const sheet=make(1800,1940,[235,233,240,255]);
function checker(x,y,w,h){for(let yy=y;yy<y+h;yy++)for(let xx=x;xx<x+w;xx++){let c=((Math.floor((xx-x)/18)+Math.floor((yy-y)/18))%2)?220:234;set(sheet,xx,yy,[c,c,c+3,255]);}}
checker(48,100,1100,390);over(sheet,ref,60,100);
checker(48,555,1100,330);over(sheet,match,62,560);
const snow=load(path.join(root,'godot/screenshots/speech-notification/1-graz-full.png'));
// Exact notification neighbourhood, with the occupied old notification strip replaced
// only in this review image by a clean snow/foliage patch immediately above it.
let bg=make(400,190);for(let y=0;y<190;y++)for(let x=0;x<400;x++){let yy=y%144;if(yy>72)yy=144-yy;set(bg,x,y,pix(snow,190+x,233+yy));}
bg=resize(bg,1100,430);over(sheet,bg,48,950);over(sheet,match,64,1000);
over(sheet,stretch,65,1490);
// Independent samples to the right.
checker(1210,110,540,600);over(sheet,resize(body,506,169),1227,145);over(sheet,resize(tail,192,192),1250,355);over(sheet,resize(chevron,128,128),1500,390);
// Join detail, same production assets, magnified 3x.
checker(1220,1000,510,350);over(sheet,resize(crop(match,0,85,145,120),435,360),1240,995);
save(sheet,path.join(dir,'sheet.png'));
const validations={files:{},nine_patch_margin:40,generated_input:'drafts/01-imagegen-blank-body.png',reference:'docs/handoff/refs/speech-bubble-concept-crop3x.png'};
for(let name of ['speech_paper.png','speech_paper_tail.png','speech_chevron.png']){let a=load(path.join(asset,name)),n0=0,edge=0;for(let y=0;y<a.h;y++)for(let x=0;x<a.w;x++){let al=pix(a,x,y)[3];if(!al)n0++;if((x===0||y===0||x===a.w-1||y===a.h-1)&&al)edge++;}validations.files[name]={width:a.w,height:a.h,format:'RGBA8',transparent_pixels:n0,nontransparent_canvas_edge:edge,sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(asset,name))).digest('hex')};}
fs.writeFileSync(path.join(dir,'validation.json'),JSON.stringify(validations,null,2));
console.log(JSON.stringify(validations,null,2));
if(process.argv.includes('--verify-protected')){const before=JSON.parse(fs.readFileSync(path.join(__dirname,'protected-before.json'))),after=fingerprints(),changed=Object.keys(before).filter(k=>before[k]!==after[k]);console.log('Protected paths changed:',changed);}
