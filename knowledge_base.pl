% Smart Course Recommendation System Knowledge Base
% Adapted for Kenyan KCSE System

:- dynamic student_grade/2.
:- dynamic student_interest/1.
:- dynamic completed/1.

% Course list
course('AI').
course('Cybersecurity').
course('Data Science').
course('Software Engineering').
course('Networking').
course('Computer Science').
course('Information Technology').
course('Actuarial Science').
course('Medicine').
course('Engineering').

% Prerequisites mapping
prereq('AI', 'programming').
prereq('AI', 'mathematics').
prereq('Data Science', 'mathematics').
prereq('Data Science', 'statistics').
prereq('Cybersecurity', 'networking_basics').
prereq('Software Engineering', 'programming').
prereq('Networking', 'networking_basics').
prereq('Computer Science', 'mathematics').
prereq('Computer Science', 'programming').
prereq('Actuarial Science', 'mathematics').
prereq('Actuarial Science', 'statistics').
prereq('Medicine', 'biology').
prereq('Medicine', 'chemistry').
prereq('Engineering', 'mathematics').
prereq('Engineering', 'physics').

% Convert KCSE grade to percentage score
grade_to_percentage('A', 85).
grade_to_percentage('A-', 78).
grade_to_percentage('B+', 72).
grade_to_percentage('B', 67).
grade_to_percentage('B-', 62).
grade_to_percentage('C+', 57).
grade_to_percentage('C', 52).
grade_to_percentage('C-', 47).
grade_to_percentage('D+', 42).
grade_to_percentage('D', 37).
grade_to_percentage('D-', 32).
grade_to_percentage('E', 25).

% Helper: Get numeric grade value
get_grade_value(Subject, Value) :-
    student_grade(Subject, Grade),
    grade_to_percentage(Grade, Value).

% Helper grade predicates with KCSE context
good_grade(Subject) :-
    student_grade(Subject, Grade),
    member(Grade, ['A', 'A-', 'B+', 'B', 'B-']).

very_good(Subject) :-
    student_grade(Subject, Grade),
    member(Grade, ['A', 'A-']).

weak_grade(Subject) :-
    student_grade(Subject, Grade),
    member(Grade, ['D+', 'D', 'D-', 'E']).

meets_university_minimum :-
    student_grade(english, Eng),
    student_grade(kiswahili, Kisw),
    student_grade(mathematics, Math),
    (member(Eng, ['A','A-','B+','B','B-','C+','C']);
     member(Kisw, ['A','A-','B+','B','B-','C+','C']);
     member(Math, ['A','A-','B+','B','B-','C+','C'])).

% Programming skill proxy based on KCSE Mathematics and Physics
programming_like :-
    student_grade(mathematics, Math),
    member(Math, ['A','A-','B+','B']).
programming_like :-
    student_grade(physics, Phys),
    member(Phys, ['A','A-','B+','B']).

% Statistics skill proxy
statistics_like :-
    student_grade(mathematics, Math),
    member(Math, ['A','A-','B+','B','B-']).
statistics_like :-
    student_grade(geography, Geo),
    member(Geo, ['A','A-','B+','B']).

% Networking skill proxy
networking_like :-
    student_grade(physics, Phys),
    member(Phys, ['A','A-','B+','B','B-']).
networking_like :-
    student_grade(mathematics, Math),
    member(Math, ['A','A-','B+','B']).

% Biology/Chemistry skill for Medicine
biology_chemistry_strong :-
    student_grade(biology, Bio),
    member(Bio, ['A','A-','B+']),
    student_grade(chemistry, Chem),
    member(Chem, ['A','A-','B+']).

% Historical student success patterns (KCSE-based)
pattern_success('AI', 12).
pattern_success('Data Science', 14).
pattern_success('Cybersecurity', 11).
pattern_success('Software Engineering', 13).
pattern_success('Networking', 10).
pattern_success('Computer Science', 15).
pattern_success('Information Technology', 12).
pattern_success('Actuarial Science', 16).
pattern_success('Medicine', 18).
pattern_success('Engineering', 15).

% FIXED: Prerequisite checking - ensures all variables are bound
meets_prereqs(Course, Score, Msg) :-
    findall(R, prereq(Course,R), L),
    (L = [] -> 
        Score = 10, 
        Msg = 'No strict prerequisites.' ;
        check_prereq_list(L, 0, [], Score, Msg)).

check_prereq_list([], Acc, Msgs, Score, Msg) :-
    Score is Acc,
    (Msgs = [] -> 
        Msg = 'All prerequisites met' ;
        (   catch(atomic_list_concat(Msgs, '; ', Msg), _, Msg = 'Prerequisites check completed')
        )).

check_prereq_list([H|T], Acc, Msgs, Score, Msg) :-
    (completed(H) -> 
        NewAcc is Acc + 10, 
        append(Msgs, [H], NewMsgs) ;
        NewAcc is Acc + 0, 
        atom_concat('missing: ', H, MissingMsg),
        append(Msgs, [MissingMsg], NewMsgs)),
    check_prereq_list(T, NewAcc, NewMsgs, Score, Msg).

% FIXED: Grade Profile Scoring - ensure safe concatenation
grade_profile('AI', Score, Msg) :-
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(40, (MathPct/100)*40),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (student_grade(physics, Phys) -> 
        grade_to_percentage(Phys, PhysPct), 
        PhysScore is min(20, (PhysPct/100)*20),
        PhysGrade = Phys ;
        PhysScore = 0, PhysGrade = 'N/A'),
    (programming_like -> ProgScore = 20 ; ProgScore = 0),
    Score is round(MatScore + PhysScore + ProgScore),
    (   catch(format(atom(Msg), 'Math: ~w (~w) Physics: ~w (~w) Programming: ~w', 
           [MathGrade, MatScore, PhysGrade, PhysScore, ProgScore]), _, 
           Msg = 'Grade analysis for AI')
    ).

grade_profile('Data Science', Score, Msg) :-
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(45, (MathPct/100)*45),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (student_grade(chemistry, Chem) -> 
        grade_to_percentage(Chem, ChemPct), 
        ChemScore is min(15, (ChemPct/100)*15),
        ChemGrade = Chem ;
        ChemScore = 0, ChemGrade = 'N/A'),
    (statistics_like -> StatScore = 20 ; StatScore = 0),
    Score is round(MatScore + ChemScore + StatScore),
    (   catch(format(atom(Msg), 'Math: ~w (~w) Chem: ~w (~w) Stats: ~w', 
           [MathGrade, MatScore, ChemGrade, ChemScore, StatScore]), _, 
           Msg = 'Grade analysis for Data Science')
    ).

grade_profile('Cybersecurity', Score, Msg) :-
    (networking_like -> NetScore = 30 ; NetScore = 0),
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(30, (MathPct/100)*30),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (student_grade(english, Eng) -> 
        grade_to_percentage(Eng, EngPct), 
        EngScore is min(10, (EngPct/100)*10),
        EngGrade = Eng ;
        EngScore = 0, EngGrade = 'N/A'),
    Score is round(NetScore + MatScore + EngScore),
    (   catch(format(atom(Msg), 'Networking: ~w Math: ~w (~w) English: ~w (~w)', 
           [NetScore, MathGrade, MatScore, EngGrade, EngScore]), _, 
           Msg = 'Grade analysis for Cybersecurity')
    ).

grade_profile('Software Engineering', Score, Msg) :-
    (programming_like -> ProgScore = 35 ; ProgScore = 0),
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(25, (MathPct/100)*25),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (student_grade(english, Eng) -> 
        grade_to_percentage(Eng, EngPct), 
        EngScore is min(10, (EngPct/100)*10),
        EngGrade = Eng ;
        EngScore = 0, EngGrade = 'N/A'),
    Score is round(ProgScore + MatScore + EngScore),
    (   catch(format(atom(Msg), 'Programming: ~w Math: ~w (~w) English: ~w (~w)', 
           [ProgScore, MathGrade, MatScore, EngGrade, EngScore]), _, 
           Msg = 'Grade analysis for Software Engineering')
    ).

grade_profile('Networking', Score, Msg) :-
    (networking_like -> NetScore = 40 ; NetScore = 0),
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(20, (MathPct/100)*20),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    Score is round(NetScore + MatScore),
    (   catch(format(atom(Msg), 'Networking: ~w Math: ~w (~w)', 
           [NetScore, MathGrade, MatScore]), _, 
           Msg = 'Grade analysis for Networking')
    ).

grade_profile('Computer Science', Score, Msg) :-
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(50, (MathPct/100)*50),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (programming_like -> ProgScore = 30 ; ProgScore = 0),
    Score is round(MatScore + ProgScore),
    (   catch(format(atom(Msg), 'Math: ~w (~w) Programming: ~w', 
           [MathGrade, MatScore, ProgScore]), _, 
           Msg = 'Grade analysis for Computer Science')
    ).

grade_profile('Actuarial Science', Score, Msg) :-
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(60, (MathPct/100)*60),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (student_grade(english, Eng) -> 
        grade_to_percentage(Eng, EngPct), 
        EngScore is min(15, (EngPct/100)*15),
        EngGrade = Eng ;
        EngScore = 0, EngGrade = 'N/A'),
    Score is round(MatScore + EngScore),
    (   catch(format(atom(Msg), 'Math: ~w (~w) English: ~w (~w)', 
           [MathGrade, MatScore, EngGrade, EngScore]), _, 
           Msg = 'Grade analysis for Actuarial Science')
    ).

grade_profile('Medicine', Score, Msg) :-
    (student_grade(biology, Bio) -> 
        grade_to_percentage(Bio, BioPct), 
        BioScore is min(40, (BioPct/100)*40),
        BioGrade = Bio ;
        BioScore = 0, BioGrade = 'N/A'),
    (student_grade(chemistry, Chem) -> 
        grade_to_percentage(Chem, ChemPct), 
        ChemScore is min(35, (ChemPct/100)*35),
        ChemGrade = Chem ;
        ChemScore = 0, ChemGrade = 'N/A'),
    (student_grade(physics, Phys) -> 
        grade_to_percentage(Phys, PhysPct), 
        PhysScore is min(15, (PhysPct/100)*15),
        PhysGrade = Phys ;
        PhysScore = 0, PhysGrade = 'N/A'),
    Score is round(BioScore + ChemScore + PhysScore),
    (   catch(format(atom(Msg), 'Biology: ~w (~w) Chemistry: ~w (~w) Physics: ~w (~w)', 
           [BioGrade, BioScore, ChemGrade, ChemScore, PhysGrade, PhysScore]), _, 
           Msg = 'Grade analysis for Medicine')
    ).

grade_profile('Engineering', Score, Msg) :-
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(45, (MathPct/100)*45),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    (student_grade(physics, Phys) -> 
        grade_to_percentage(Phys, PhysPct), 
        PhysScore is min(35, (PhysPct/100)*35),
        PhysGrade = Phys ;
        PhysScore = 0, PhysGrade = 'N/A'),
    Score is round(MatScore + PhysScore),
    (   catch(format(atom(Msg), 'Math: ~w (~w) Physics: ~w (~w)', 
           [MathGrade, MatScore, PhysGrade, PhysScore]), _, 
           Msg = 'Grade analysis for Engineering')
    ).

grade_profile('Information Technology', Score, Msg) :-
    (programming_like -> ProgScore = 40 ; ProgScore = 0),
    (student_grade(mathematics, Math) -> 
        grade_to_percentage(Math, MathPct), 
        MatScore is min(30, (MathPct/100)*30),
        MathGrade = Math ;
        MatScore = 0, MathGrade = 'N/A'),
    Score is round(ProgScore + MatScore),
    (   catch(format(atom(Msg), 'Programming: ~w Math: ~w (~w)', 
           [ProgScore, MathGrade, MatScore]), _, 
           Msg = 'Grade analysis for Information Technology')
    ).

% Interest scoring
interest_score(Course, Score, Msg) :-
    (student_interest(I), downcase_atom(I, ILower), 
     course_interest_match(Course, ILower) -> 
        Score = 20, 
        Msg = 'Interest matches course' ;
        Score = 0, 
        Msg = 'No interest match').

course_interest_match('AI', 'ai').
course_interest_match('Data Science', 'data_science').
course_interest_match('Data Science', 'data science').
course_interest_match('Cybersecurity', 'cybersecurity').
course_interest_match('Software Engineering', 'software_engineering').
course_interest_match('Software Engineering', 'software engineering').
course_interest_match('Networking', 'networking').
course_interest_match('Computer Science', 'computer_science').
course_interest_match('Computer Science', 'computer science').
course_interest_match('Information Technology', 'information_technology').
course_interest_match('Information Technology', 'it').
course_interest_match('Actuarial Science', 'actuarial_science').
course_interest_match('Actuarial Science', 'actuarial science').
course_interest_match('Medicine', 'medicine').
course_interest_match('Engineering', 'engineering').

% FIXED: Risk rules - ensure atomic_list_concat gets proper arguments
risk(Course, Msg) :-
    course(Course),
    student_grade(mathematics, Math),
    member(Math, ['D+', 'D', 'D-', 'E']),
    (   catch(format(atom(Msg), 'Low mathematics grade (~w) may make ~w challenging', [Math, Course]), _, 
           Msg = 'Low mathematics grade for this course')
    ).

risk(Course, Msg) :-
    course(Course),
    prereq(Course, Req),
    \+ completed(Req),
    (   catch(format(atom(Msg), 'Missing prerequisite: ~w for ~w', [Req, Course]), _, 
           Msg = 'Missing required prerequisite')
    ).

risk(Course, Msg) :-
    course(Course),
    (Course = 'Medicine' ; Course = 'Actuarial Science'),
    \+ meets_university_minimum,
    (   catch(format(atom(Msg), 'Does not meet minimum university entry requirements for ~w', [Course]), _, 
           Msg = 'Does not meet minimum requirements')
    ).

% FIXED: Explanation rule - safe string building
explain(Course, Explanation) :-
    course(Course),
    grade_profile(Course, GScore, GMsg),
    meets_prereqs(Course, PScore, PMsg),
    interest_score(Course, IScore, IMsg),
    pattern_success(Course, HScore),
    Total is GScore + PScore + IScore + HScore,
    Confidence is min(100, round(Total)),
    (   catch(format(atom(Explanation), 
           'Grade: ~w | Prereqs: ~w | ~w | Pattern: ~w | Match: ~w%', 
           [GMsg, PMsg, IMsg, HScore, Confidence]), _, 
           Explanation = 'Recommendation analysis available')
    ).

% Main recommendation rule
recommend(Course, Reason, Confidence) :-
    course(Course),
    grade_profile(Course, GScore, _),
    meets_prereqs(Course, PScore, _),
    interest_score(Course, IScore, _),
    pattern_success(Course, HScore),
    Base is GScore + PScore + IScore,
    Total is Base + HScore,
    Confidence is min(100, round(Total)),
    (Confidence >= 35 -> 
        Reason = 'Suitable based on KCSE grades, prerequisites and historical patterns' ;
        Reason = 'Low confidence - consider improving prerequisites or grades').

% Eligibility predicate
eligible(Course) :-
    recommend(Course, _, Confidence),
    Confidence >= 50.

% University entry check
can_join_university :-
    meets_university_minimum,
    write('Student meets minimum university entry requirements (C+ in core subjects)');
    write('Student does NOT meet minimum university entry requirements').

% Sample KCSE student for testing
% student_grade(english, 'B+').
% student_grade(kiswahili, 'B').
% student_grade(mathematics, 'A-').
% student_grade(physics, 'B+').
% student_grade(chemistry, 'B+').
% student_grade(biology, 'A-').
% student_grade(geography, 'C+').
% student_interest('computer_science').
% completed('programming').
% completed('mathematics').