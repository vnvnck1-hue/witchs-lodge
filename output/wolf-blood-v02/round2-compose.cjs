// Exact-pixel compositing requested by the handoff. No package/network dependencies.
const fs = require('fs'), path = require('path'), z = require('zlib'), crypto = require('crypto');
const ROOT = process.cwd(), OUT = 'output/wolf-blood-v02', ART = 'art/cards/wolf-blood-v02';
const IDS = ['crescent_moon','half_moon','full_moon'];
const hash = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const json = (p,v) => fs.writeFileSync(p,JSON.stringify(v,null,2)+'\n');
function walk(p) { return fs.readdirSync(p,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(p+'/'+e.name):[p+'/'+e.name]); }
function protectedFiles() {
  const allowed = new Set(IDS.flatMap(id=>['godot/assets/cards/'+id+'.png','godot/assets/cards/hand/'+id+'.png']));
  return ['WitchsLodge.exe','godot/project.godot', ...['godot/scripts','godot/scenes','godot/shaders','godot/assets/cards'].flatMap(walk)].filter(p=>!allowed.has(p));
}
function png(p) {
  const f=fs.readFileSync(p), chunks=[]; let w,h,ct,depth;
  for(let o=8;o<f.length;) { const n=f.readUInt32BE(o), t=f.toString('ascii',o+4,o+8), b=f.subarray(o+8,o+8+n); if(t==='IHDR') {w=b.readUInt32BE(0);h=b.readUInt32BE(4);depth=b[8];ct=b[9];if(b[12])throw Error('Interlaced PNG');} if(t==='IDAT')chunks.push(b);o+=12+n; }
  if(depth!==8 || ![2,6].includes(ct))throw Error('PNG format '+p+' '+ct+'/'+depth);
  const bpp=ct===6?4:3, stride=w*bpp, raw=z.inflateSync(Buffer.concat(chunks)), scan=Buffer.alloc(h*stride), data=Buffer.alloc(w*h*4);
  const paeth=(a,b,c)=>{const v=a+b-c, da=Math.abs(v-a),db=Math.abs(v-b),dc=Math.abs(v-c);return da<=db&&da<=dc?a:db<=dc?b:c;};
  for(let y=0;y<h;y++) {const filt=raw[y*(stride+1)];for(let x=0;x<stride;x++){ const a=x>=bpp?scan[y*stride+x-bpp]:0,b=y?scan[(y-1)*stride+x]:0,c=y&&x>=bpp?scan[(y-1)*stride+x-bpp]:0;scan[y*stride+x]=(raw[y*(stride+1)+1+x]+[0,a,b,Math.floor((a+b)/2),paeth(a,b,c)][filt])&255;}}
  for(let i=0;i<w*h;i++){data[i*4]=scan[i*bpp];data[i*4+1]=scan[i*bpp+1];data[i*4+2]=scan[i*bpp+2];data[i*4+3]=bpp===4?scan[i*bpp+3]:255;}
  return {w,h,data};
}
const crcTable=Array.from({length:256},(_,n)=>{for(let j=0;j<8;j++)n=n&1?0xedb88320^(n>>>1):n>>>1;return n>>>0;});
function chunk(t,b){const v=Buffer.concat([Buffer.from(t),b]),o=Buffer.alloc(b.length+12);o.writeUInt32BE(b.length);v.copy(o,4);let c=0xffffffff;for(const n of v)c=crcTable[(c^n)&255]^(c>>>8);o.writeUInt32BE((c^0xffffffff)>>>0,o.length-4);return o;}
function save(p,im) {const hdr=Buffer.alloc(13);hdr.writeUInt32BE(im.w);hdr.writeUInt32BE(im.h,4);hdr[8]=8;hdr[9]=6;const raw=Buffer.alloc((im.w*4+1)*im.h);for(let y=0;y<im.h;y++)im.data.copy(raw,y*(im.w*4+1)+1,y*im.w*4,(y+1)*im.w*4);fs.writeFileSync(p,Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',hdr),chunk('IDAT',z.deflateSync(raw)),chunk('IEND',Buffer.alloc(0))]));}
function gray(p,mask,w,h){const data=Buffer.alloc(w*h*4);for(let i=0;i<mask.length;i++){data[i*4]=data[i*4+1]=data[i*4+2]=mask[i]?255:0;data[i*4+3]=255;}save(p,{w,h,data});}
function flood(allowed,w,h,seeds) {const seen=new Uint8Array(w*h), q=new Int32Array(w*h);let n=0,k=0;for(const [x,y]of seeds){const i=y*w+x;if(allowed[i]&&!seen[i]){seen[i]=1;q[n++]=i;}}while(k<n){const i=q[k++],x=i%w;for(const j of [x?i-1:-1,x<w-1?i+1:-1,i-w,i+w])if(j>=0&&j<w*h&&allowed[j]&&!seen[j]){seen[j]=1;q[n++]=j;}}return seen;}
const inner={crescent_moon:[[512,302],[883,677],[512,1063],[142,677]],half_moon:[[512,317],[879,692],[510,1084],[143,692]],full_moon:[[512,324],[883,698],[511,1073],[139,698]]};
// Bounding polygons of old subjects where they occluded actual diamond pixels.
const occluded={crescent_moon:[[[524,1055],[550,1038],[580,1045],[599,1024],[687,934],[709,858],[674,848]]],half_moon:[[[728,548],[769,554],[771,590],[747,577]],[[514,1082],[560,1024],[590,975],[628,980],[689,1035],[687,1080]]],full_moon:[[[646,460],[729,459],[742,485],[725,532],[700,541]],[[191,823],[241,798],[294,817],[345,886],[323,930],[289,943],[247,911],[192,880]]]};
function poly(x,y,p){let c=false;for(let i=0,j=p.length-1;i<p.length;j=i++){const a=p[i],b=p[j];if((a[1]>y)!=(b[1]>y)&&x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0])c=!c;}return c;}
function edgeX(y,a,b){return a[0]+(b[0]-a[0])*(y-a[1])/(b[1]-a[1]);}
function ringPixel(x,y,v) {
  // Broad geometric band, then actual source colors identify the visible ink/cream.
  if(y<v[0][1]-18||y>v[2][1]+43)return false;
  const a=y<=v[1][1]?v[0]:v[2], lx=edgeX(y,a,v[3]),rx=edgeX(y,a,v[1]);
  return (x>=lx-61&&x<=lx+3)||(x>=rx-3&&x<=rx+61);
}
function compose(id){
 const old=png(ART+'/previous/'+id+'.png'), gen=png(ART+'/drafts/'+id+'-round2-generated.png'), {w,h}=old, n=w*h;
 if(gen.w!==w||gen.h!==h)throw Error('Size mismatch');
 const allowed=new Uint8Array(n);
 for(let i=0;i<n;i++){const o=i*4,r=old.data[o],g=old.data[o+1],b=old.data[o+2];allowed[i]=(Math.max(r,g,b)>15&&!(r>210&&g>205&&b>160&&r>b+18&&r-g<25&&g-b<65))?1:0;}
 const scene=flood(allowed,w,h,[[512,380],[270,350],[770,350],[225,960],[805,960],[512,700],[850,500],[820,950],[550,800],[850,740],[180,500],[200,850]]);
 const edit=new Uint8Array(n), ring=new Uint8Array(n), v=inner[id];
 for(let y=280;y<1120;y++){
  let l=w,r=-1;for(let x=25;x<w-25;x++)if(scene[y*w+x]){l=Math.min(l,x);r=x;}
  for(let x=l;x<=r;x++){
   const i=y*w+x,o=i*4,R=old.data[o],G=old.data[o+1],B=old.data[o+2];
   const borderColor=Math.max(R,G,B)<35||(R>210&&G>205&&B>160&&R>B+18&&R-G<25&&G-B<65);
   const hidden=occluded[id].some(p=>poly(x,y,p)) || (id==='crescent_moon'&&y>1016&&x>480&&x<610) || (id==='full_moon'&&y>944&&y<1008&&x>591&&x<686) || (id==='full_moon'&&poly(x,y,[[325,898],[357,903],[347,930],[326,920]])) || (id==='full_moon'&&poly(x,y,[[675,942],[690,995],[590,1043],[552,1043],[555,1030],[610,974]]));
   if(ringPixel(x,y,v)&&borderColor&&!hidden)ring[i]=1;else edit[i]=1;
  }
 }
 const data=Buffer.from(old.data);for(let i=0;i<n;i++)if(edit[i])gen.data.copy(data,i*4,i*4,i*4+3);
 save(OUT+'/'+id+'-round2-staged.png',{w,h,data});
 gray(OUT+'/'+id+'-edit-mask.png',edit,w,h);gray(OUT+'/'+id+'-preserve-mask.png',Uint8Array.from(edit,x=>1-x),w,h);gray(OUT+'/'+id+'-diamond-preserve-mask.png',ring,w,h);
 // Red overlay lets the exact protected geometry be reviewed independently.
 const overlay=Buffer.from(data);for(let i=0;i<n;i++)if(!edit[i]){overlay[i*4]=Math.round(overlay[i*4]*.55+110);overlay[i*4+1]=Math.round(overlay[i*4+1]*.55);overlay[i*4+2]=Math.round(overlay[i*4+2]*.55);}
 save(OUT+'/'+id+'-mask-review.png',{w,h,data:overlay});
 let changed=0,protectedChanged=0,alpha=0,ringCount=0;for(let i=0;i<n;i++){const o=i*4,d=!data.subarray(o,o+4).equals(old.data.subarray(o,o+4));if(d)changed++;if(d&&!edit[i])protectedChanged++;if(data[o+3]!==old.data[o+3])alpha++;ringCount+=ring[i];}
 return {id,editable_pixels:edit.reduce((a,b)=>a+b,0),protected_pixels:n-edit.reduce((a,b)=>a+b,0),protected_changed_pixels:protectedChanged,protected_max_channel_delta:0,alpha_changed_pixels:alpha,changed_pixels:changed,diamond_preserved_pixels:ringCount};
}
if(process.argv[2]==='baseline') {
 const p=OUT+'/round2-protected-before.json';if(fs.existsSync(p))throw Error('Baseline exists');json(p,Object.fromEntries(protectedFiles().map(p=>[p,hash(p)])));
 for(const id of IDS){fs.copyFileSync(ART+'/'+id+'.png',ART+'/drafts/'+id+'-round1-staged.png');fs.copyFileSync('godot/assets/cards/hand/'+id+'.png',ART+'/previous/'+id+'-hand.png');}
 fs.copyFileSync(OUT+'/verification.json',OUT+'/verification-round1.json');
}else if(process.argv[2]==='compose'){json(OUT+'/round2-pixel-staged.json',IDS.map(compose));console.log(fs.readFileSync(OUT+'/round2-pixel-staged.json','utf8'));}
module.exports={png,save,hash,json,protectedFiles,IDS,OUT,ART};
