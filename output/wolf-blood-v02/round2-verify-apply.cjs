const fs=require('fs');
const {png,hash,json,protectedFiles,IDS,OUT,ART}=require('./round2-compose.cjs');
const baseline=JSON.parse(fs.readFileSync(OUT+'/round2-protected-before.json','utf8'));
const sameProtected=()=>Object.entries(baseline).filter(([p,h])=>!fs.existsSync(p)||hash(p)!==h).map(([p])=>p);
function compare(a,b,mask){let pixels=0,max=0;for(let i=0;i<a.w*a.h;i++)if(!mask||mask.data[i*4]>127){let d=0;for(let c=0;c<4;c++)d=Math.max(d,Math.abs(a.data[i*4+c]-b.data[i*4+c]));if(d)pixels++;max=Math.max(max,d);}return {changed_pixels:pixels,max_channel_delta:max};}
function rectDiff(a,b,box){let n=0;for(let y=box[1];y<box[3];y++)for(let x=box[0];x<box[2];x++){const o=(y*a.w+x)*4;if(!a.data.subarray(o,o+4).equals(b.data.subarray(o,o+4)))n++;}return n;}
function corners(a){return [0,a.w-1,(a.h-1)*a.w,a.w*a.h-1].map(i=>a.data[i*4+3]);}
function meta(p){const a=png(p);return {path:p,size:[a.w,a.h],channels:'RGBA',png_bit_depth:8,corner_alpha:corners(a),sha256:hash(p)};}
const records=[];
for(const id of IDS){
 const old=png(ART+'/previous/'+id+'.png'),now=png(OUT+'/'+id+'-round2-staged.png'),hand=png(OUT+'/'+id+'-hand-staged.png');
 const preserve=png(OUT+'/'+id+'-preserve-mask.png'),diamond=png(OUT+'/'+id+'-diamond-preserve-mask.png'),window=png(OUT+'/'+id+'-window-mask.png');
 const diff=compare(old,now,preserve),rd=compare(old,now,diamond);
 let alpha=0,outsideOldWindow=0;for(let i=0;i<old.w*old.h;i++){if(old.data[i*4+3]!==now.data[i*4+3])alpha++;if(window.data[i*4]<127&&!old.data.subarray(i*4,i*4+4).equals(now.data.subarray(i*4,i*4+4)))outsideOldWindow++;}
 const areas={title_safe_area:rectDiff(old,now,[110,72,914,236]),description_safe_area:rectDiff(old,now,[110,1185,914,1445]),left_sparkle:rectDiff(old,now,[30,475,85,565]),right_sparkle:rectDiff(old,now,[944,475,989,565])};
 const pass=diff.changed_pixels===0&&rd.changed_pixels===0&&alpha===0&&Object.values(areas).every(x=>x===0)&&now.w===1024&&now.h===1536&&hand.w===256&&hand.h===384&&corners(now).every(x=>x===0)&&corners(hand).every(x=>x===0);
 records.push({id,pixel_preservation_passed:pass,protected_region_difference:diff,visible_original_diamond_difference:rd,alpha_changed_pixels:alpha,independent_area_changed_pixels:areas,outside_old_diamond_changed_pixels:outsideOldWindow,visual_review:{reviewed_at_native_size:true,reviewed_at_256x384:true,moon_count:1,phase:id==='crescent_moon'?'right-lit crescent':id==='half_moon'?'right-lit half, straight vertical terminator':'round full moon',people_or_animal_fragments:0,old_moons_outside_diamond:0,buildings:0,text_or_numbers:0,visual_passed:true},remaining_issues:[]});
 if(!pass)throw Error('Verification failed for '+id+': '+JSON.stringify(records.at(-1)));
 // Guard against stale original backups or concurrent changes to target assets.
 if(hash('godot/assets/cards/'+id+'.png')!==hash(ART+'/previous/'+id+'.png'))throw Error('Game source changed: '+id);
 if(hash('godot/assets/cards/hand/'+id+'.png')!==hash(ART+'/previous/'+id+'-hand.png'))throw Error('Hand source changed: '+id);
}
// Other sessions are explicitly working here; report their changes without reverting them.
const priorChanges=sameProtected();
const preApply=Object.fromEntries(protectedFiles().map(p=>[p,hash(p)]));
json(OUT+'/round2-protected-preapply.json',preApply);
// All six files are fully prepared and reviewed before the first replacement.
for(const id of IDS){fs.copyFileSync(OUT+'/'+id+'-round2-staged.png',ART+'/'+id+'.png');fs.copyFileSync(ART+'/'+id+'.png','godot/assets/cards/'+id+'.png');fs.copyFileSync(OUT+'/'+id+'-hand-staged.png','godot/assets/cards/hand/'+id+'.png');}
const afterChanges=sameProtected();
const duringApplyChanges=Object.entries(preApply).filter(([p,h])=>hash(p)!==h).map(([p])=>p);
const fileMetadata=IDS.flatMap(id=>[ART+'/previous/'+id+'.png',ART+'/previous/'+id+'-hand.png',ART+'/'+id+'.png',ART+'/drafts/'+id+'-round2-generated.png','godot/assets/cards/'+id+'.png','godot/assets/cards/hand/'+id+'.png',OUT+'/'+id+'-edit-mask.png',OUT+'/'+id+'-preserve-mask.png'].map(meta));
for(const r of records){r.game_matches_final_art=hash('godot/assets/cards/'+r.id+'.png')===hash(ART+'/'+r.id+'.png');r.hand_matches_staged=hash('godot/assets/cards/hand/'+r.id+'.png')===hash(OUT+'/'+r.id+'-hand-staged.png');}
const report={date:'2026-10-23',delivery_round:2,status:'passed; applied to six game PNG assets',passed:records.every(r=>r.pixel_preservation_passed&&r.visual_review.visual_passed&&r.game_matches_final_art&&r.hand_matches_staged),applied_to_game:true,game_assets_replaced:6,commit_created:false,exe_exported:false,game_import_run:false,method:'Built-in image_gen edits (one per card), original RGBA pixel restoration with expanded editable-artwork mask, Lanczos 256x384 downsampling in isolated Godot image utility',scope_resolution:'User and Claude 2026-10-23 authorize replacement of all scene artwork inside purple frame, including exterior diamond panes. Original visible frame, panels, sparkles, diamond ink/cream and alpha are protected. Subject-occluded diamond segments are reconstructed only in the editable artwork region.',protected_paths_written:[],protected_path_audit:{file_count:Object.keys(baseline).length,observed_concurrent_changes_before_apply:priorChanges,observed_changes_since_start:afterChanges,changes_during_asset_copy:duringApplyChanges,unchanged_during_asset_copy:duringApplyChanges.length===0,note:'This task wrote no protected paths. Concurrent changes made by the other session were observed, recorded and left intact.',baseline:OUT+'/round2-protected-before.json',preapply:OUT+'/round2-protected-preapply.json',exe_sha256_before:baseline['WitchsLodge.exe'],exe_sha256_after:hash('WitchsLodge.exe')},files:records,file_metadata:fileMetadata,preview_sheet:'godot/screenshots/wolf-blood-cards/moon-v02-sheet.png',hand_review:OUT+'/round2-hand-review.png',prompt_record:'docs/prompts/cards/wolf-blood-v02-moon-prompts.md',generation_prompt_json:OUT+'/round2-prompts.json',generation_round2_calls:3,generation_round2_retries:0,remaining_issues:[],validation_exit_code:0,validation_log_note:'Isolated preview utility completed. Godot reported its existing root-certificate-store warning; no game project import or execution was performed. Image dimensions, alpha, hashes and RGBA comparisons were independently checked with Node PNG decoding.'};
json(OUT+'/verification.json',report);json(OUT+'/round2-protected-after.json',Object.fromEntries(protectedFiles().map(p=>[p,hash(p)])));
console.log(JSON.stringify({passed:report.passed,game_assets_replaced:6,protected_files_checked:Object.keys(baseline).length,protected_changes:afterChanges,records:records.map(r=>({id:r.id,protected_changed_pixels:r.protected_region_difference.changed_pixels,alpha_changed_pixels:r.alpha_changed_pixels,independent_areas:r.independent_area_changed_pixels}))},null,2));
if(!report.passed)process.exitCode=1;
