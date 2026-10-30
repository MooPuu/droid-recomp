import json
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('catalog.json', 'r', encoding='utf-8') as f:
    catalog = json.load(f)

apps = catalog['apps']
print(f"Total apps in catalog: {len(apps)}")

# Specific curated translations for major games
CURATED_BLURBS = {
    'undertale-android': "لعبة الـ RPG الشهيرة التي لا يتعين عليك فيها هزيمة أي شخص. دعم كامل للتحكم بشاشة اللمس وأذرع التحكم الخارجية.",
    'balatro': "أداة بناء تلقائية تعتمد على ملفات اللعبة الأصلية من Steam لاستخراج الكود البرمجي وإضافة أزرار التحكم باللمس وبناء ملف APK أصلي لأندرويد.",
    'another-metroid-2-remake-am2r': "نسخة أندرويد أصلية للعبة إعادة إحياء Metroid 2 الكلاسيكية ثنائية الأبعاد. تتميز برسوميات 60 إطاراً في الثانية وفيزياء مشابهة لـ Zero Mission ودعم كامل لأذرع التحكم.",
    'doom-doom-ii-heretic-hexen': "حزمة بورتات متميزة تتضمن 10 من محركات Doom المعتمدة عالمياً (مثل GZDoom و LZDoom و PrBoom+) مع دعم كامل للمودات وأزرار التحكم باللمس.",
    'forza-horizon': "إعادة تجميع ثنائية ثابتة لنسخة Xbox 360 من لعبة سباقات كولورادو المفتوحة الشهيرة، تعمل بشكل أصلي على أندرويد عبر معمارية ARM64.",
    'god-of-war-iii-remastered': "مشروع إعادة تجميع تجريبي لمنصة أندرويد يهدف إلى تشغيل اللعبة الأسطورية بشكل مباشر على معالجات ARM64 الرائدة.",
    'half-life-amp-goldsrc-games': "إعادة كتابة مفتوحة المصدر بالكامل لمحرك GoldSrc من Valve. يشغل طور القصة للعبة Half-Life والمودات و Counter-Strike 1.6 واللعب الجماعي بشكل أصلي على أندرويد.",
    'half-life-2-amp-portal': "بورت ARM64 أصلي لمحرك Source من Valve. يشغل الحملات الكاملة لـ Half-Life 2 و Portal مباشرة على أندرويد بدون أي استهلاك للمحاكي.",
    'halo-combat-evolved': "بورت أصلي بالكامل لمعمارية ARM64 مبني على فك شفرة نسخة إكس بوكس الأصلية. يدعم 60+ إطاراً في الثانية، واللعب بشاشة منقسمة، وأذرع تحكم البلوتوث.",
    'mario-kart-wii': "بورت أندرويد أصلي لمعمارية ARM64 للعبة Mario Kart Wii وحزمة التعديلات Retro Rewind، تم بناؤه عبر تقنية إعادة التجميع الثابتة ويتجاوز المحاكي ليعمل بالسرعة الكاملة.",
    'need-for-speed-most-wanted-2005': "إعادة تجميع ثابتة لمعمارية ARM64 للعبة مطاردات الشرطة وسباقات الشوارع الكلاسيكية من EA لعام 2005، مع دعم 60 إطاراً وأزرار اللمس وأذرع التحكم.",
    'need-for-speed-underground-2': "إعادة تجميع ثنائية ثابتة لملف تشغيل الحاسوب (SPEED2.EXE) إلى كود C محمول ونقي تم تجميعه أصلياً لأندرويد بدون محاكاة.",
    'skies-of-arcadia-legends-recompiled': "إعادة تجميع مسبقة من PowerPC إلى كود C أصلي للعبة الآر بي جي الكلاسيكية من GameCube، تعمل بسرعة 60 إطاراً في الثانية على معالجات Snapdragon.",
    'sonic-3-amp-knuckles': "نسخة محسنة بالكامل للشاشات العريضة من Sonic 3 & Knuckles تعمل بمحرك Oxygen المخصص مع موسيقى رقمية فائقة النقاء وحركة سلسة بمعدل 60 إطاراً.",
    'super-mario-galaxy': "بورت أندرويد أصلي 100% لمعمارية ARM64 للعبة منصات الجاذبية الكونية الشهيرة، يعمل أصلياً عبر مكتبات Vulkan ويدعم التوجيه بالجيروسكوب.",
    'super-mario-sunshine': "بورت أندرويد أصلي لمغامرة ماريو الاستوائية على GameCube، يعمل بسرعة 60 إطاراً ثابتة مع دعم الشاشات العريضة وتحكم سلس.",
    'the-legend-of-zelda-the-wind-waker-hd': "بورت أصلي مبني بإعادة التجميع الثنائية الثابتة لنسخة Wii U مباشرة على معالجات أندرويد، يدعم الشاشة العريضة الأصلية والإضاءة المحسنة.",
    'call-of-duty-4-modern-warfare': "بورت أصلي لمعمارية ARM64 للعبة التصويب العسكرية الثورية من Infinity Ward، يعمل بثبات على 60 إطاراً بدقة 1080p على مختلف المعالجات.",
    'call-of-duty-modern-warfare-2': "مشروع إعادة تجميع ثنائية لنسخة Xbox 360 لتشغيل اللعبة الأصلية مباشرة على أجهزة أندرويد مع تسريع رسومي عبر Vulkan.",
    'grand-theft-auto-iv-liberty-recompiled': "إعادة تجميع ثنائية ثابتة لملف تشغيل Xbox 360 إلى كود C أصلي، تعمل مباشرة على أجهزة أندرويد مع معالجة رسومية عبر Vulkan.",
    'ace-combat-3-electrosphere': "إعادة تجميع ثابتة أصلية للعبة القتال الجوي الشهيرة على PlayStation، مع رسوميات محسنة و60 إطاراً ودعم كامل للشاشات العريضة.",
    'alien-vs-predator': "بورت أصلي مفتوح المصدر للعبة الرعب والتصويب الكلاسيكية للحاسوب، يدعم التحكم اللمسي وأذرع التحكم الخارجية ومعدل إطارات مرتفع.",
    'amnesia-the-dark-descent': "بورت أصلي لمعمارية ARM64 للعبة رعب البقاء النفسي الشهيرة، يعمل بكامل المؤثرات البصرية والصوتية الأصلية على أندرويد.",
    'aquaria': "بورت أندرويد أصلي لتحفة المغامرات المائية المستقلة الحائزة على جوائز، مع دعم أزرار اللمس الكاملة والشاشات الحديثة عالية الدقة.",
    'arx-fatalis': "بورت أصلي بمحرك Arx Libertatis للعبة تعاقب الأدوار الغامرة الكلاسيكية، يتيح رسم التعاويذ السحرية عبر شاشة اللمس مباشرة.",
    'blood-fresh-supply': "بورت محرك أصلي للعبة التصويب الكلاسيكية الملحمية، يدعم الإطارات العالية وأصوات 3D والمودات المخصصة.",
    'castlevania-symphony-of-the-night': "إعادة تجميع ثابتة لمعمارية ARM64 لتحفة Castlevania الأسطورية، مع شاشات عريضة وإلغاء شاشات التحميل وزمن استجابة معدوم.",
    'celeste-classic': "بورت أصلي للعبة المنصات الدقيقة الكلاسيكية، مع دعم شاشات اللمس وأذرع التحكم الخارجية بمعدل 60 إطاراً ثابتاً.",
    'chrono-trigger': "إعادة تجميع ثنائية متقدمة لأسطورة الآر بي جي الخالدة، تعمل بكفاءة مطلقة مع جودة صوتية غير مضغوطة وأداء فائق النقاء.",
    'clive-barkers-undying': "بورت أصلي لمحرك Unreal Tournament الكلاسيكي لتشغيل لعبة الرعب القوطية الشهيرة بشكل مباشر وسلس على أندرويد.",
    'command-and-conquer-red-alert': "بورت محرك ChronoDivide و OpenRA لتشغيل لعبة الاستراتيجية الأسطورية مع أزرار تحكم لمسية متطورة مصممة للأجهزة الذكية.",
    'crash-bandicoot-n-sane-trilogy': "مشروع إعادة تجميع أولي يهدف لنقل ثلاثية كراش المحسنة لمعالجات ARM64 عبر واجهات Vulkan الحديثة.",
    'crash-team-racing': "إعادة تجميع ثابتة أصلية لنسخة PS1 الكلاسيكية، مع دعم الشاشات العريضة 16:9 ومعدل 60 إطاراً واللعب التنافسي المحلي.",
    'daggerfall-unity': "النسخة المعاد بناؤها بالكامل بمحرك Unity للعبة The Elder Scrolls II: Daggerfall، تقدم تحسينات بصرية هائلة ودعماً كاملاً للمودات على أندرويد.",
    'dark-souls-recompiled': "مشروع إعادة تجميع ثنائية متقدم للعبة الأكشن والآر بي جي الأسطورية لتشغيلها بشكل أصلي بدون محاكاة على أجهزة أندرويد الرائدة.",
    'dead-space-2008': "مشروع بورت وإعادة تجميع للعبة رعب الفضاء الشهيرة لعام 2008، يعمل على استغلال عتاد أندرويد عبر واجهة Vulkan الحديثة.",
    'deus-ex': "بورت محرك أصلي لتحفة الخيال العلمي والآر بي جي الغامرة، مع واجهة مستخدم مخصصة للشاشات اللمسية ودعم أذرع التحكم الخارجية.",
    'diablo': "بورت DevilutionX الأصلي فائق الدقة لتحفة الآر بي جي الكلاسيكية، يدعم الشاشات العريضة وأجهزة التحكم واللعب الجماعي عبر الإنترنت.",
    'diablo-ii-resurrected': "مشروع إعادة بناء أصلي لأصول ومحرك Diablo II الكلاسيكي ليعمل مباشرة على بيئة أندرويد بأداء سلس وموفر للطاقة.",
    'fallout-1': "بورت Fallout Community Edition الأصلي للعبة تعاقب الأدوار التاريخية، مصمم بالكامل للعمل باللمس وبدقة عرض الأجهزة اللوحية والهواتف الحديثة.",
    'fallout-2': "بورت أصلي مباشر للعبة Fallout 2 الشهيرة بنظام تحكم لمسي ذكي وترقية لدقة العرض وسلاسة فائقة في الأداء.",
    'final-fantasy-vii': "إعادة تجميع ثابتة لمعمارية ARM64 للعبة Final Fantasy VII الأسطورية، مع دعم ترقية النماذج ثلاثية الأبعاد والموسيقى الأوركسترالية.",
    'final-fantasy-viii': "بورت أصلي وإعادة تجميع للعبة تعاقب الأدوار المحبوبة، يقدم شاشات عريضة وزمن تحميل شبه معدوم وسرعة إطارات ثابتة.",
    'final-fantasy-ix': "إعادة تجميع متطورة لنسخة PS1 مع دعم استبدال الخلفيات الأصلية بنسخ فائقة الوضوح عبر الذكاء الاصطناعي وأداء فائق النعومة.",
    'f-zero-x': "إعادة تجميع ثابتة أصلية من كود Nintendo 64 إلى C أصلي، تقدم سرعة 60 إطاراً خارقة ودقة 4K نقية مع استجابة تحكم فورية.",
    'goldeneye-007': "إعادة تجميع ثابتة للعبة الجاسوسية الأسطورية على N64، تتيح التصويب بالعصا المزدوجة الحديثة ونسبة عرض 16:9 وسرعة 60 إطاراً.",
    'grand-theft-auto-iii': "بورت re3 الأصلي المبني على الهندسة العكسية الكاملة لمحرك GTA III، مع إضاءة محسنة وزمن تحميل فوري ودعم كامل للأذرع والشاشات العريضة.",
    'grand-theft-auto-vice-city': "بورت reVC الأصلي المبني على الكود المصدري المفكك لمحرك Vice City، يعمل بأداء فائق ومعدل 60 إطاراً ثابتاً مع دعم المودات الأصلية.",
    'grand-theft-auto-san-andreas': "مشروع إعادة بناء أصلي لمحرك RenderWare لتحقيق تجربة San Andreas الأصلية للحاسوب مع دعم إكساءات HD والإضافات الحديثة.",
    'heroes-of-might-and-magic-iii': "مشروع VCMI مفتوح المصدر الملحمي الذي يعيد بناء محرك HoMM3 بالكامل على أندرويد مع دعم الذكاء الاصطناعي المتقدم وشاشات اللمس.",
    'hollow-knight': "بورت أندرويد أصلي غير رسمي لتحفة المترويدفينيا الخالدة، يوفر استجابة فورية للتحكم باللمس ومعدل 120 إطاراً للشاشات السريعة.",
    'homeworld': "بورت الكود المصدري الأصلي لتحفة الاستراتيجية الفضائية ثلاثية الأبعاد، مع واجهة مستخدم ملائمة للشاشات اللمسية ودعم دقة العرض العالية.",
    'hotline-miami': "بورت أصلي عالي الكفاءة للعبة الأكشن والموسيقى الصاخبة، يدعم أذرع التحكم الخارجية بمعدل 60 إطاراً ثابتاً.",
    'jack-and-daxter-the-precursor-legacy': "مشروع OpenGOAL الأصلي الذي يعيد بناء كود GOAL الخاص بـ Naughty Dog ليعمل بشكل أصلي على معمارية ARM64 بمعدل 60 إطاراً وشاشات عريضة.",
    'jak-ii': "بورت OpenGOAL الأصلي للعبة Jak II، يقدم رسوميات ناصعة ومعدل إطارات مضاعف وتحكماً عصرياً متطوراً على أندرويد.",
    'max-payne': "مشروع تحسين وبورت أصلي لمعمارية ARM64 للعبة الحركة الكلاسيكية، مع دعم تأثير Bullet Time السلس وأذرع التحكم الحديثة.",
    'medieval-ii-total-war': "بورت أصلي لمحرك اللعبة الاستراتيجية التاريخية الكبرى، يتيح قيادة آلاف الجنود في معارك تكتيكية مباشرة على أندرويد.",
    'metal-gear-solid': "إعادة تجميع ثابتة أصلية لتحفة التسلل التاريخية لهيديو كوجيما، تدعم الشاشات العريضة وحزم الإكساءات المحسنة وسرعة استجابة فائقة.",
    'morrowind': "مشروع OpenMW الأصلي الرائد الذي يعيد كتابة محرك The Elder Scrolls III: Morrowind بالكامل، مع فيزياء حديثة ودعم كامل للمودات و60 إطاراً.",
    'perfect-dark': "إعادة تجميع ثابتة أصلية لكود Nintendo 64 المصدري، تدعم التحكم الحديث بعصاتي اللعب وتعديل معدل الإطارات إلى 60 FPS والشاشات العريضة.",
    'quake-iii-arena': "بورت ioquake3 الأصلي لمعمارية ARM64، يقدم أسرع تجربة تصويب جماعية بدقة 120 FPS مع دعم الماوس ولوحة المفاتيح وأذرع التحكم.",
    'rayman-2-the-great-escape': "بورت أصلي مبهج لتحفة المنصات ثلاثية الأبعاد الكلاسيكية، يعمل بدقة عرض عالية وسلاسة 60 إطاراً على كافة أجهزة أندرويد.",
    'resident-evil-2-1998': "إعادة تجميع ثابتة للعبة رعب البقاء الأيقونية لعام 1998، مع دعم خلفيات فائقة الوضوح تم ترقيتها بالذكاء الاصطناعي وتحكم عصري سلس.",
    'resident-evil-4-2005': "مشروع إعادة تجميع وبورت لمعمارية ARM64 للعبة Resident Evil 4 الكلاسيكية، يتيح اللعب بدون محاكي مع رسوميات 60 إطاراً ناصعة.",
    'rollercoaster-tycoon-2': "مشروع OpenRCT2 الأصلي المفتوح المصدر، يتيح بناء مدن الملاهي وإدارتها بدقة عالية وتحكم لمسي متقن وسلس على أندرويد.",
    'silent-hill': "إعادة تجميع ثنائية ثابتة لكود PS1 الأصلي، مع تصحيح هندسة الرسوميات PGXP وإزالة تشويه المضلعات لتقديم أنقى تجربة رعب نفسي.",
    'simcity-2000': "بورت محرك أصلي لمحاكاة بناء المدن الكلاسيكية الخالدة، مع دعم إيماءات اللمس الحديثة وتكبير الشاشة السلس.",
    'star-wars-knights-of-the-old-republic': "مشروع xoreos و OpenKotOR لبناء محرك كلاسيكية الخيال العلمي والآر بي جي ليعمل أصلياً بأعلى كفاءة على معالجات ARM64.",
    'super-mario-64': "بورت sm64-port المصدري الأصلي الأسطوري، يوفر 60 إطاراً ودقة 4K حقيقية وزاوية كاميرا حرة ومودات إكساءات عالية الدقة.",
    'the-legend-of-zelda-majoras-mask': "مشروع 2Ship2Harkinian لإعادة التجميع الثابتة لأسطورة Majora's Mask، مع دعم 60 إطاراً والتصويب بالجيروسكوب ومئات التحسينات العصرية.",
    'the-legend-of-zelda-ocarina-of-time': "مشروع Ship of Harkinian الأسطوري لإعادة تجميع Ocarina of Time، يقدم شاشات عريضة وإطارات عالية وزاوية كاميرا حرة وتحكماً حديثاً.",
    'tomb-raider-1-openlara': "مشروع OpenLara الأصلي المذهل الذي يعيد صياغة مغامرة لارا كروفت الأولى بمعدل 60 إطاراً وإضاءة ديناميكية وتأثيرات ماء مائية مذهلة.",
    'wipeout-pure-special-edition': "بورت أصلي وإعادة تجميع للعبة السباقات المستقبلية الخارقة، مع دعم 120 FPS وشاشات عريضة وموسيقى إلكترونية فائقة النقاء."
}

def get_ar_blurb(game):
    gid = game['id']
    name = game.get('name', game.get('game', ''))
    b = game.get('blurb', '').strip()
    
    if gid in CURATED_BLURBS:
        return CURATED_BLURBS[gid]
        
    if b.startswith("High-fidelity native Android recompilation of"):
        return f"نسخة أندرويد أصلية عالية الدقة ومعاد تجميعها للعبة {name}. تعمل بشكل أصلي ومباشر بدون استهلاك المحاكي مع تحسينات حديثة."
    if b.startswith("High-performance native Android port of"):
        return f"بورت أندرويد أصلي عالي الأداء للعبة {name}. يعمل بشكل أصلي ومباشر على معمارية ARM64 مع تحسينات حديثة."
    if b.startswith("Native Android port of"):
        return f"بورت أندرويد أصلي للعبة {name}. يعمل بشكل أصلي على أندرويد مع تحسينات الأداء والتحكم."
    if b.startswith("Native Android source port of"):
        return f"بورت أندرويد أصلي من الكود المصدري للعبة {name}. يعمل بشكل مباشر على معمارية ARM64."
    if b.startswith("Static recompilation of"):
        return f"إعادة تجميع ثابتة أصلية للعبة {name} تعمل مباشرة على معمارية ARM64 بدون محاكاة."
    if b.startswith("Community source port of"):
        return f"بورت مصدري مجتمعي للعبة {name} مع تحسينات بصرية ودعم شاشات اللمس لأجهزة أندرويد."
        
    cleaned = re.sub(r'^[✓⚡]\s+[A-Za-z0-9\s•]+\d{4}\s+[^\n\r]+?(Native|Full|Angel|Static|Ahead|Automated|Premium|Xbox|100%|srceng|COD4|OpenCE)', r'\1', b)
    if cleaned != b and len(cleaned) > 20:
        b = cleaned
        
    replacements = [
        (r"The acclaimed RPG where you don't have to destroy anyone\. Full touch D-pad and gamepad compatibility\.",
         "لعبة الـ RPG الشهيرة التي لا يتعين عليك فيها هزيمة أي شخص. دعم كامل للتحكم بشاشة اللمس وأذرع التحكم الخارجية."),
        (r"Runs natively without emulator overhead with modern enhancements\.",
         "تعمل بشكل أصلي ومباشر بدون استهلاك المحاكي مع تحسينات حديثة."),
        (r"Runs natively on ARM64 architecture with modern enhancements\.",
         "يعمل بشكل أصلي ومباشر على معمارية ARM64 مع تحسينات حديثة."),
        (r"Runs natively on Android without emulation\.",
         "يعمل بشكل أصلي على أندرويد بدون محاكاة."),
        (r"Full single-player and multiplayer support\.",
         "دعم كامل للعب الفردي والجماعي."),
        (r"Bring your own legally owned game files\.",
         "يتطلب توفير ملفات اللعبة المملوكة بشكل قانوني."),
        (r"Features crisp 60 FPS sprite rendering",
         "يتميز بعرض رسوميات سريعة بمعدل 60 إطاراً في الثانية"),
        (r"and full controller support",
         "ودعم كامل لأذرع التحكم"),
        (r"with modern enhancements",
         "مع تحسينات تقنية حديثة"),
        (r"Zero emulation overhead",
         "بدون أي استهلاك للمحاكي"),
        (r"Full touch controls and gamepad support",
         "تحكم كامل باللمس ودعم أذرع التحكم الخارجية")
    ]
    
    res = b
    for pat, rep in replacements:
        res = re.sub(pat, rep, res, flags=re.IGNORECASE)
        
    if re.search(r'[a-zA-Z]{5,}', res):
        return f"بورت أندرويد أصلي عالي الأداء ومعاد تجميعه للعبة {name}. يعمل بشكل مباشر على معمارية ARM64 بدون محاكي مع دعم أذرع التحكم وشاشات اللمس."
        
    return res

FEATURE_MAP = {
    'Native ARM64 Execution (Zero JIT Overhead)': 'تشغيل أصلي على معمارية ARM64 (بدون استهلاك JIT)',
    '60/120 FPS High Frame-Rate Rendering': 'عرض رسومي فائق السرعة بمعدل 60 / 120 إطاراً في الثانية',
    'Widescreen & 16:9 Display Enhancements': 'دعم كامل للشاشات العريضة ونسبة 16:9',
    'Configurable Touch Controls & Gyro Aiming': 'أزرار تحكم باللمس قابلة للتخصيص ودعم التصويب بالجيروسكوب',
    'High Efficiency Shader Pipeline': 'معالجة تظليل عالية الكفاءة وموفرة للطاقة',
    'Full Physical Controller Auto-Mapping': 'تعيين تلقائي كامل لأذرع التحكم الخارجية',
    'Adreno Turnip Vulkan Driver Tested': 'تم اختباره بنجاح مع تعريف Adreno Turnip Vulkan',
    'Local Multiplayer & Controller Support': 'دعم اللعب الجماعي المحلي وأذرع التحكم المتعددة',
    'HD Texture Packs & Visual Overhauls': 'دعم حزم الإكساءات عالية الدقة HD والترقيات البصرية',
    'Native Widescreen & Gyroscope Aiming': 'عرض عريض أصلي ودعم التصويب بالجيروسكوب',
    'High Performance Zero-Emulation Pipeline': 'أداء فائق وتشغيل مباشر بدون محاكاة',
    'Low Latency Audio & Soundfont Support': 'صوتيات بزمن استجابة فائق السرعة ودعم Soundfont',
    'Dynamic Lighting & Texture Filtering': 'إضاءة ديناميكية وتنعيم متقدم للإكساءات',
    'Modern Dual-Analog Sticks & Gyro Aiming': 'دعم عصي التحكم المزدوجة الحديثة والتصويب بالجيروسكوب',
    'Native ARM64 Multi-Core Rendering': 'معالجة رسومية متعددة الأنوية أصيلة على ARM64',
    'Lossless High Resolution Audio Pipeline': 'مسار صوتي عالي الدقة دون فقدان الجودة',
    'Save State Management & Memory Backups': 'إدارة نقاط الحفظ والنسخ الاحتياطي للذاكرة',
    'Vulkan 1.3 & OpenGL ES 3.2 Compatible': 'توافق كامل مع مكتبات Vulkan 1.3 و OpenGL ES 3.2',
    'Custom High Resolution Texture Injection': 'إمكانية إدراج إكساءات مخصصة فائقة الدقة HD',
    'Custom Soundfonts & CD-Audio Music Packs': 'دعم حزم الموسيقى و Soundfonts المخصصة',
    'Advanced Turnip & Qualcomm Adreno Profiling': 'تحسين متقدم لمعالجات Qualcomm Adreno و Turnip',
    'Zero Emulation Latency (Direct C/C++ Code)': 'زمن استجابة فوري بفضل كود C/C++ المباشر',
    'Ultra Fast Load Times & Instant Asset Streaming': 'تحميل فائق السرعة وتدفق فوري لملفات اللعبة',
    'Clean-Room Recompilation Architecture': 'معمارية إعادة تجميع نظيفة 100% بدون كود مغلق',
    'Zero JIT Compilation Stutter': 'انعدام تقطيع التجميع الفوري JIT تماماً',
    'Instant Save States & SRAM Preservation': 'حفظ فوري لحالات اللعب والذاكرة الدائمة',
    'Direct Hardware Access (No Virtualization)': 'وصول مباشر لعتاد الجهاز بدون بيئات افتراضية'
}

def translate_feature(feat):
    feat = feat.strip()
    if feat in FEATURE_MAP:
        return FEATURE_MAP[feat]
    for k, v in FEATURE_MAP.items():
        if k.lower() in feat.lower():
            return v
    return f"ميزة محسنة: {feat}"

for app in apps:
    app['blurb_ar'] = get_ar_blurb(app)
    app['features_ar'] = [FEATURE_MAP.get(f, translate_feature(f)) for f in app.get('features', [])]

print("Successfully added blurb_ar and features_ar to all games!")

with open('catalog.json', 'w', encoding='utf-8') as f:
    json.dump(catalog, f, ensure_ascii=False, indent=2)

with open('catalog.js', 'w', encoding='utf-8') as f:
    f.write("window.DROIDRECOMP_CATALOG = " + json.dumps(catalog, indent=2, ensure_ascii=False) + ";\n")

with open('droid_recomp_app/assets/catalog.json', 'w', encoding='utf-8') as f:
    json.dump(catalog, f, ensure_ascii=False, indent=2)

print("Saved updated catalog.json, catalog.js, and droid_recomp_app/assets/catalog.json!")
