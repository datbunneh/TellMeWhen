﻿
local L = LibStub("AceLocale-3.0"):NewLocale("TellMeWhen", "koKR", false)
if not L then return end










-- L["ALPHAPANEL_TITLE"] = ""
-- L["BleedDamageTaken"] = ""
-- L["Bleeding"] = ""
-- L["BonusAgiStr"] = ""
-- L["BonusArmor"] = ""
-- L["BonusMana"] = ""
-- L["BonusStamina"] = ""
-- L["BurstHaste"] = ""
-- L["BurstManaRegen"] = ""
-- L["CASTERFORM"] = ""
L["CHOOSENAME_DIALOG"] = [=[/ 버프가 / Debuff이 아이콘이 모니터에 원하는 이름이나 ID가 맞춤법 / 능력 / 항목의 입력하세요. 당신이 그들을 분리하여 여러 Buffs / Debuffs를 추가할 수 있습니다 ';'
애완 동물의 능력은 SpellIDs을 사용해야합니다.]=] -- Needs review
L["CHOOSENAME_DIALOG_DDDEFAULT"] = "미리 정의된 철자 세트" -- Needs review
L["CHOOSENAME_EQUIVS_TOOLTIP"] = "이 메뉴에 buffs / debuffs의 미리 정의된 집합을 선택할 수 있습니다." -- Needs review
L["CMD_ERROR"] = "전투에서 설정 TellMeWhen 전환할 수 없습니다" -- Needs review
L["CMD_OPTIONS"] = "옵션" -- Needs review
L["CMD_RESET"] = "초기화" -- Needs review
-- L["CONDITIONPANEL_ALIVE"] = ""
-- L["CONDITIONPANEL_ALIVE_DESC"] = ""
L["CONDITIONPANEL_AND"] = "및" -- Needs review
L["CONDITIONPANEL_ANDOR"] = "및 / 또는" -- Needs review
-- L["CONDITIONPANEL_COMBO"] = ""
L["CONDITIONPANEL_ECLIPSE_DESC"] = "이클립스 -100 (달 일식은) 100의 범위를 가지고 (일식)  연구  nPercentages는 같은 방식으로 작동 :.  연구  nInput는 -80 당신은 80의 값을 작동하도록 아이콘을 원한다면 음력 전력. " -- Needs review
L["CONDITIONPANEL_EQUALS"] = "같음" -- Needs review
-- L["CONDITIONPANEL_EXISTS"] = ""
-- L["CONDITIONPANEL_EXISTS_DESC"] = ""
L["CONDITIONPANEL_GREATER"] = "초과" -- Needs review
L["CONDITIONPANEL_GREATEREQUAL"] = "이상 또는 동등 그레이터" -- Needs review
-- L["CONDITIONPANEL_ICON"] = ""
-- L["CONDITIONPANEL_ICON_DESC"] = ""
L["CONDITIONPANEL_LESS"] = "미만" -- Needs review
L["CONDITIONPANEL_LESSEQUAL"] = "이상 또는 동등 덜" -- Needs review
L["CONDITIONPANEL_NOTEQUAL"] = "같지 않음" -- Needs review
L["CONDITIONPANEL_OPERATOR"] = "연산자" -- Needs review
L["CONDITIONPANEL_OR"] = "또는" -- Needs review
-- L["CONDITIONPANEL_POWER"] = ""
L["CONDITIONPANEL_POWER_DESC"] = "단위는 고양이 형태의 사제는,  단위 등 전사하는 경우에는 연구  nrage 경우 에너지를 확인합니다" -- Needs review
L["CONDITIONPANEL_RESET"] = "삭제" -- Needs review
L["CONDITIONPANEL_TITLE"] = "TellMeWhen 조건 편집기" -- Needs review
L["CONDITIONPANEL_TYPE"] = "종류" -- Needs review
L["CONDITIONPANEL_UNIT"] = "단위" -- Needs review
L["CONDITIONPANEL_VALUE"] = "퍼센트" -- Needs review
-- L["CONDITIONPANEL_VALUEN"] = ""
-- L["CONDTWARN"] = ""
-- L["COPY"] = ""
-- L["COPYPANEL_GROUP"] = ""
-- L["COPYPANEL_ICON"] = ""
-- L["COPYPANEL_TITLE"] = ""
-- L["COPYSETTINGS"] = ""
-- L["CrowdControl"] = ""
-- L["Curse"] = ""
-- L["DURATIONPANEL_TITLE"] = ""
-- L["Disarmed"] = ""
-- L["Disease"] = ""
-- L["Disoriented"] = ""
-- L["ECLIPSE_DIRECTION"] = ""
-- L["ECLIPSE_DIRECTION_DESC"] = ""
-- L["EDITORPANEL_TITLE"] = ""
-- L["FALSE"] = ""
-- L["FROM"] = ""
-- L["Feared"] = ""
-- L["GENABLEBUTTON"] = ""
-- L["GROUP"] = ""
-- L["GROUPICON"] = ""
-- L["GROUPRESETMSG"] = ""
-- L["HPSSWARN"] = ""
L["ICONALPHAPANEL_ALPHA"] = "사용 가능 / 현재 알파 레벨" -- Needs review
L["ICONALPHAPANEL_ALPHA_DESC"] = "능력 / 현재 사용할 때 슬라이드 아이콘에 대한 알파 수준을 설정하는" -- Needs review
-- L["ICONALPHAPANEL_CNDTALPHA"] = ""
-- L["ICONALPHAPANEL_CNDTALPHA_DESC"] = ""
-- L["ICONALPHAPANEL_DURATIONALPHA"] = ""
-- L["ICONALPHAPANEL_DURATIONALPHA_DESC"] = ""
-- L["ICONALPHAPANEL_FAKEHIDDEN"] = ""
-- L["ICONALPHAPANEL_FAKEHIDDEN_DESC"] = ""
-- L["ICONALPHAPANEL_STACKALPHA"] = ""
-- L["ICONALPHAPANEL_STACKALPHA_DESC"] = ""
-- L["ICONALPHAPANEL_THISISSET_DESC"] = ""
L["ICONALPHAPANEL_UNALPHA"] = "불가능 / 없지만 알파 레벨" -- Needs review
L["ICONALPHAPANEL_UNALPHA_DESC"] = "능력 / 결석 사용할 수 없게되었을 때 슬라이드 아이콘에 대한 알파 수준을 설정하는" -- Needs review
L["ICONMENU_ABSENT"] = "없지만" -- Needs review
L["ICONMENU_ADDCONDITION"] = "조건 추가" -- Needs review
L["ICONMENU_ALPHA"] = "알파" -- Needs review
L["ICONMENU_ALWAYS"] = "항상" -- Needs review
L["ICONMENU_BARS"] = "바" -- Needs review
-- L["ICONMENU_BOTH"] = ""
L["ICONMENU_BUFF"] = "버프" -- Needs review
L["ICONMENU_BUFFDEBUFF"] = "프로그램 / Debuff 광" -- Needs review
L["ICONMENU_BUFFSHOWWHEN"] = "보이기시 버프 / debuff" -- Needs review
L["ICONMENU_BUFFTYPE"] = "버프 또는 debuff?" -- Needs review
-- L["ICONMENU_CAST"] = ""
-- L["ICONMENU_CASTSHOWWHEN"] = ""
-- L["ICONMENU_CAST_DESC"] = ""
L["ICONMENU_CHOOSENAME"] = "/ 광은 / etc 선택 마법 / 아이템." -- Needs review
L["ICONMENU_CLEAR"] = "삭제 설정" -- Needs review
L["ICONMENU_COOLDOWN"] = "재사용 대기 시간" -- Needs review
-- L["ICONMENU_COOLDOWNCHECK"] = ""
-- L["ICONMENU_COOLDOWNCHECK_DESC"] = ""
L["ICONMENU_COOLDOWNTYPE"] = "재사용 대기 시간 형식" -- Needs review
L["ICONMENU_DEBUFF"] = "Debuff" -- Needs review
-- L["ICONMENU_DISPEL"] = ""
L["ICONMENU_DURATIONANDCD"] = "CD 기간>" -- Needs review
-- L["ICONMENU_DURATION_MAX_DESC"] = ""
-- L["ICONMENU_DURATION_MIN_DESC"] = ""
-- L["ICONMENU_EDIT"] = ""
L["ICONMENU_EDITCONDITION"] = "조건을 수정" -- Needs review
L["ICONMENU_EITHER"] = "모든 단위" -- Needs review
L["ICONMENU_ENABLE"] = "아이콘 사용" -- Needs review
L["ICONMENU_FOCUSTARGET"] = "Focustarget" -- Needs review
L["ICONMENU_FRIEND"] = "우호 단위" -- Needs review
-- L["ICONMENU_HIDEUNEQUIPPED"] = ""
L["ICONMENU_HOSTILE"] = "적대적 단위" -- Needs review
-- L["ICONMENU_ICONS"] = ""
L["ICONMENU_INVERTBARS"] = "채우기가 바"
L["ICONMENU_ITEM"] = "항목"
L["ICONMENU_MANACHECK"] = "전원 체크?" -- Needs review
-- L["ICONMENU_MANACHECK_DESC"] = ""
-- L["ICONMENU_META"] = ""
-- L["ICONMENU_META_DESC"] = ""
-- L["ICONMENU_MOUSEOVER"] = ""
-- L["ICONMENU_MOUSEOVERTARGET"] = ""
-- L["ICONMENU_MULTISTATECD"] = ""
-- L["ICONMENU_MULTISTATECD_DESC"] = ""
-- L["ICONMENU_ONLYINTERRUPTIBLE"] = ""
L["ICONMENU_ONLYMINE"] = "만 보여주면 스스로 캐스트" -- Needs review
L["ICONMENU_OPTIONS"] = "추가 옵션" -- Needs review
L["ICONMENU_PETTARGET"] = "Pettarget" -- Needs review
L["ICONMENU_PRESENT"] = "현재" -- Needs review
L["ICONMENU_RANGECHECK"] = "범위 확인?" -- Needs review
-- L["ICONMENU_RANGECHECK_DESC"] = ""
L["ICONMENU_REACT"] = "단위 반응" -- Needs review
L["ICONMENU_REACTIVE"] = "대응 조치 마법 또는 능력" -- Needs review
L["ICONMENU_SETALPHA"] = "설정 알파 레벨" -- Needs review
-- L["ICONMENU_SETALPHAMOD"] = ""
L["ICONMENU_SHOWCBAR"] = "재사용 대기 시간 표시 / 타이머 바" -- Needs review
L["ICONMENU_SHOWPBAR"] = "쇼 파워 바" -- Needs review
L["ICONMENU_SHOWTIMER"] = "표시 타이머" -- Needs review
-- L["ICONMENU_SHOWTIMERTEXT"] = ""
-- L["ICONMENU_SHOWTIMERTEXT_DESC"] = ""
L["ICONMENU_SHOWWHEN"] = "아이콘 표시되면" -- Needs review
L["ICONMENU_SPELL"] = "철자 또는 능력" -- Needs review
L["ICONMENU_STACKS_MAX_DESC"] = "아이콘을 표시하는 데 필요한 분위기의 스택의 최대수" -- Needs review
L["ICONMENU_STACKS_MIN_DESC"] = "아이콘을 표시하는 데 필요한 분위기의 스택의 최소 번호" -- Needs review
L["ICONMENU_TARGETTARGET"] = "Targetstarget" -- Needs review
L["ICONMENU_TOTEM"] = "/ 비 집고 양이인가 토템" -- Needs review
-- L["ICONMENU_TOTEM_DESC"] = ""
L["ICONMENU_TYPE"] = "아이콘 형식" -- Needs review
L["ICONMENU_UNIT"] = "유닛 보는" -- Needs review
L["ICONMENU_UNUSABLE"] = "불가능" -- Needs review
L["ICONMENU_USABLE"] = "사용 가능" -- Needs review
-- L["ICONMENU_VEHICLE"] = ""
L["ICONMENU_WPNENCHANT"] = "임시 무기 반갑습니다" -- Needs review
L["ICONMENU_WPNENCHANTTYPE"] = "무기 슬롯 모니터" -- Needs review
-- L["ICONTOCHECK"] = ""
L["ICON_TOOLTIP1"] = "TellMeWhen"
L["ICON_TOOLTIP2"] = "오른쪽 아이콘을 클릭 옵션에 대한 추가 옵션 블리자드 인터페이스 옵션 메뉴에 / 잠금 및 addon을 사용 tmw 입력합니다..." -- Needs review
-- L["ImmuneToMagicCC"] = ""
-- L["ImmuneToStun"] = ""
-- L["Incapacitated"] = ""
-- L["IncreasedAP"] = ""
-- L["IncreasedCrit"] = ""
-- L["IncreasedDamage"] = ""
-- L["IncreasedPhysHaste"] = ""
-- L["IncreasedSPsix"] = ""
-- L["IncreasedSPten"] = ""
-- L["IncreasedSpellHaste"] = ""
-- L["IncreasedStats"] = ""
-- L["LDB_TOOLTIP1"] = ""
-- L["LDB_TOOLTIP2"] = ""
-- L["MOON"] = ""
-- L["Magic"] = ""
-- L["ManaRegen"] = ""
-- L["NONE"] = ""
-- L["OUTLINE_NO"] = ""
-- L["OUTLINE_THICK"] = ""
-- L["OUTLINE_THIN"] = ""
-- L["PhysicalDmgTaken"] = ""
-- L["Poison"] = ""
-- L["PushbackResistance"] = ""
L["RESIZE"] = "크기 조정" -- Needs review
L["RESIZE_TOOLTIP"] = "를 클릭하고 크기를 변경하려면 드래그" -- Needs review
-- L["RLWARN"] = ""
-- L["ReducedArmor"] = ""
-- L["ReducedAttackSpeed"] = ""
-- L["ReducedCastingSpeed"] = ""
-- L["ReducedHealing"] = ""
-- L["ReducedPhysicalDone"] = ""
-- L["Resistances"] = ""
-- L["Rooted"] = ""
-- L["STACKSPANEL_TITLE"] = ""
-- L["SUN"] = ""
-- L["Silenced"] = ""
-- L["SpellCritTaken"] = ""
-- L["SpellDamageTaken"] = ""
-- L["Stunned"] = ""
-- L["TO"] = ""
-- L["TRUE"] = ""
L["UIPANEL_ALLRESET"] = "재설정 모든 아이콘" -- Needs review
-- L["UIPANEL_BARIGNOREGCD"] = ""
-- L["UIPANEL_BARIGNOREGCD_DESC"] = ""
L["UIPANEL_BARTEXTURE"] = "바 텍스쳐" -- Needs review
-- L["UIPANEL_CLOCKIGNOREGCD"] = ""
-- L["UIPANEL_CLOCKIGNOREGCD_DESC"] = ""
L["UIPANEL_COLOR"] = "의 / 기간 바 색상 재사용 대기 시간" -- Needs review
-- L["UIPANEL_COLORS"] = ""
-- L["UIPANEL_COLOR_ABSENT"] = ""
-- L["UIPANEL_COLOR_ABSENT_DESC"] = ""
L["UIPANEL_COLOR_COMPLETE"] = "CD / 기간 완료" -- Needs review
L["UIPANEL_COLOR_COMPLETE_DESC"] = "재사용 대기 시간 / 기간이 완료되는 막대의 색상" -- Needs review
-- L["UIPANEL_COLOR_DESC"] = ""
L["UIPANEL_COLOR_OOM"] = "파워 컬러 출력의" -- Needs review
L["UIPANEL_COLOR_OOM_DESC"] = "농담 효과 그리고 당신은 마법을 행사할 / runicpower / 분노 / 초점 / 에너지 mana이 부족 아이콘 알파" -- Needs review
L["UIPANEL_COLOR_OOR"] = "색상 범위를 벗어 버리고" -- Needs review
L["UIPANEL_COLOR_OOR_DESC"] = "농담 효과 및 아이콘의 알파 당신이 마법을 행사할 대상의 범위에 있지 않습니다" -- Needs review
-- L["UIPANEL_COLOR_PRESENT"] = ""
-- L["UIPANEL_COLOR_PRESENT_DESC"] = ""
L["UIPANEL_COLOR_STARTED"] = "/ 기간 시작 CD" -- Needs review
L["UIPANEL_COLOR_STARTED_DESC"] = "재사용 대기 시간은 / 기간을 방금 시작한 바 색상" -- Needs review
L["UIPANEL_COLUMNS"] = "항목" -- Needs review
-- L["UIPANEL_CONDENSE"] = ""
L["UIPANEL_DRAWEDGE"] = "강조 타이머 에지" -- Needs review
L["UIPANEL_DRAWEDGE_DESC"] = "하이라이트 가시성을 높이기 위해서 재사용 대기 시간 타이머 (시계 애니메이션)의 가장자리" -- Needs review
L["UIPANEL_ENABLEGROUP"] = "그룹 사용" -- Needs review
-- L["UIPANEL_FONT"] = ""
-- L["UIPANEL_FONT_DESC"] = ""
-- L["UIPANEL_FONT_OUTLINE"] = ""
-- L["UIPANEL_FONT_OUTLINE_DESC"] = ""
-- L["UIPANEL_FONT_SIZE"] = ""
-- L["UIPANEL_FONT_SIZE_DESC"] = ""
L["UIPANEL_GROUPRESET"] = "위치 초기화" -- Needs review
L["UIPANEL_GROUPRESETHEADER"] = "위치 초기화" -- Needs review
-- L["UIPANEL_GROUPS"] = ""
L["UIPANEL_ICONGROUP"] = "아이콘 그룹 " -- Needs review
-- L["UIPANEL_ICONSPACING"] = ""
-- L["UIPANEL_ICONSPACING_DESC"] = ""
L["UIPANEL_LOCK"] = "잠금 AddOn" -- Needs review
L["UIPANEL_LOCKUNLOCK"] = "잠금 AddOn을 잠금 /" -- Needs review
-- L["UIPANEL_MAINOPT"] = ""
-- L["UIPANEL_NOCOUNT"] = ""
-- L["UIPANEL_NOCOUNT_DESC"] = ""
-- L["UIPANEL_NOTINVEHICLE"] = ""
-- L["UIPANEL_NUMGROUPS"] = ""
-- L["UIPANEL_NUMGROUPS_DESC"] = ""
L["UIPANEL_ONLYINCOMBAT"] = "오직 전투에 표시" -- Needs review
L["UIPANEL_PRIMARYSPEC"] = "기본 사양" -- Needs review
-- L["UIPANEL_RELOAD"] = ""
L["UIPANEL_ROWS"] = "행" -- Needs review
L["UIPANEL_SECONDARYSPEC"] = "보조 사양"
-- L["UIPANEL_SPEC"] = ""
L["UIPANEL_STANCE"] = "보기에있는 동안 :" -- Needs review
L["UIPANEL_SUBTEXT1"] = "이 옵션은 숫자를, 배치, 그리고 행동 알림 아이콘을 변경할 수 있습니다." -- Needs review
L["UIPANEL_SUBTEXT2"] = "은 아이콘이 잠겨 일할 때 잠금이 해제되면 / 크기 아이콘 그룹을 이동할 수있는 권리 기타 설정에 대한 개별 아이콘을 클릭하십시오 및 / 또는 잠금 해제 잠금 '/ tmw'을 입력할 수도 '/ tellmewhen'을하실 수 있습니다..." -- Needs review
L["UIPANEL_TOOLTIP_ALLRESET"] = "재설정 데이터와 위치의 모든 아이콘" -- Needs review
L["UIPANEL_TOOLTIP_COLUMNS"] = "설정이 그룹에 아이콘 열 개수" -- Needs review
-- L["UIPANEL_TOOLTIP_CONDENSE"] = ""
L["UIPANEL_TOOLTIP_ENABLEGROUP"] = "보기와 아이콘이 그룹을 활성화" -- Needs review
L["UIPANEL_TOOLTIP_GROUPRESET"] = "재설정이 그룹의 위치" -- Needs review
-- L["UIPANEL_TOOLTIP_NOTINVEHICLE"] = ""
L["UIPANEL_TOOLTIP_ONLYINCOMBAT"] = "유일한 전투 중에 아이콘이 그룹 표시를 확인하십시오" -- Needs review
L["UIPANEL_TOOLTIP_PRIMARYSPEC"] = "기본 사양이 활성 상태 아이콘이 그룹 표시를 확인하십시오" -- Needs review
L["UIPANEL_TOOLTIP_ROWS"] = "설정이 그룹에 아이콘 행 수를" -- Needs review
L["UIPANEL_TOOLTIP_SECONDARYSPEC"] = "보조 사양이 활성 상태 아이콘이 그룹 표시를 확인하십시오" -- Needs review
L["UIPANEL_TOOLTIP_UPDATEINTERVAL"] = "세트 / 등은 지나칠 정도로 바에 영향을주지 않는다. 제로는 가능한 한 빨리하고, 알파, 조건을 숨길 수 있습니다. 로어 값은 로우 엔드에 대한 프레임 속도에 큰 영향을 미칠 수 컴퓨터 " -- Needs review
L["UIPANEL_UNLOCK"] = "AddOn을 잠금 해제" -- Needs review
L["UIPANEL_UPDATEINTERVAL"] = "업데이트 간격" -- Needs review