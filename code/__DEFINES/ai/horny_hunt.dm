// The horny hunt: phases, reactions, meters and tuning. Blackboard keys live in hostile.dm.

// Hunt phases, stored in BB_HORNY_PHASE.
#define HORNY_PHASE_NOTICE "notice"
#define HORNY_PHASE_STALK "stalk"
#define HORNY_PHASE_SEIZE "seize"
#define HORNY_PHASE_SUBDUE "subdue"
#define HORNY_PHASE_USE "use"
#define HORNY_PHASE_BREAK_OFF "break_off"
#define HORNY_PHASE_PRESENT "present"

// Reactions fed to /datum/ai_controller/proc/horny_react() by the target, the scene or other systems.
#define HORNY_REACT_HIT "hit"
#define HORNY_REACT_RANGED_HIT "ranged_hit"
#define HORNY_REACT_GRAB_BROKEN "grab_broken"
#define HORNY_REACT_SHOVED_OFF "shoved_off"
#define HORNY_REACT_CLENCH "clench"
#define HORNY_REACT_YIELD "yield"
#define HORNY_REACT_TEASE "tease"
#define HORNY_REACT_SEDUCE "seduce"
#define HORNY_REACT_EDGE "edge"
#define HORNY_REACT_CLIMAX "climax"

// What a furious hunter does, set per family profile.
#define HORNY_BREAK_OFF_NONE "none"
#define HORNY_BREAK_OFF_SUBDUE "subdue"
#define HORNY_BREAK_OFF_CIRCLE "circle"
#define HORNY_BREAK_OFF_SINK "sink"
#define HORNY_BREAK_OFF_FLEE "flee"
#define HORNY_BREAK_OFF_ENRAGE "enrage"

// Temper: 0 calm, 30 rough, 70 furious. Decays while the hunt runs.
#define HORNY_TEMPER_ROUGH 30
#define HORNY_TEMPER_FURIOUS 70
#define HORNY_TEMPER_MAX 100
#define HORNY_TEMPER_DECAY_PER_SECOND 0.5
#define HORNY_TEMPER_PER_DAMAGE 1
#define HORNY_TEMPER_RANGED_HIT 15
#define HORNY_TEMPER_GRAB_BROKEN 10
#define HORNY_TEMPER_SHOVED_OFF 10
#define HORNY_TEMPER_CLENCH 5

// Lust: the hunter's own climaxes and the target's counterplay push it; at the top the hunter presents.
#define HORNY_LUST_MAX 100
#define HORNY_LUST_AFTER_PRESENT 60
#define HORNY_LUST_PER_CLIMAX 40
#define HORNY_LUST_PER_CLENCH 5
#define HORNY_LUST_PER_TEASE 5
#define HORNY_LUST_PER_SEDUCE 15
#define HORNY_LUST_PER_EDGE 10
#define HORNY_LUST_PER_SECOND_NEAR_AROUSED 1
#define HORNY_LUST_TARGET_AROUSAL 80

// Mortal danger beats lust: damage from the hunted target past this share of max health ends the hunt and starts a fight.
#define HORNY_LETHAL_DAMAGE_SHARE 0.35
// A hurt hunter needs less of it from the target before it fights back for real.
#define HORNY_LETHAL_HURT_FRACTION 0.5
#define HORNY_LETHAL_HURT_DAMAGE_SHARE 0.15

// Timing and ranges.
#define HORNY_NOTICE_TIME (1.5 SECONDS)
#define HORNY_SPRINT_RANGE 6
#define HORNY_RUSH_TIME (6 SECONDS)
#define HORNY_RUSH_SPEED_MULT 0.6
#define HORNY_FLINCH_TIME (0.5 SECONDS)
#define HORNY_BREAK_OFF_TIME (20 SECONDS)
#define HORNY_SUBDUE_WINDOW (30 SECONDS)
#define HORNY_CIRCLE_RANGE 4
#define HORNY_FLEE_RANGE 7
#define HORNY_PRESENT_TIME (20 SECONDS)
#define HORNY_LOST_SIGHT_GIVE_UP (10 SECONDS)
#define HORNY_CHASE_STALL_TIMEOUT (90 SECONDS)
#define HORNY_INTERACTION_TIMEOUT (5 MINUTES)
#define HORNY_PREP_PAUSE (1 SECONDS)
#define HORNY_SIGHT_RANGE 9
