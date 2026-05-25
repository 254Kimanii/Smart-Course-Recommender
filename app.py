import os
from flask import Flask, render_template, request, jsonify
from pyswip import Prolog

app = Flask(__name__)

# Initialize Prolog and consult knowledge base
prolog = Prolog()
kb_path = os.path.join(os.path.dirname(__file__), 'knowledge_base.pl')
prolog.consult(kb_path)


def reset_student_facts():
    """Remove previous student facts from Prolog session."""
    try:
        list(prolog.query('retractall(student_grade(_, _))'))
        list(prolog.query('retractall(student_interest(_))'))
        list(prolog.query('retractall(completed(_))'))
    except Exception:
        pass


def assert_student_data(data):
    # grades: dict of subject->grade (grade is a letter like 'A', 'B+', etc.)
    grades = data.get('grades', {})
    for subj, val in grades.items():
        if val:  # Only assert non-empty grades
            # Prolog atom names avoid spaces; keep subject keys lower-case
            # Assert grade as an atom (e.g., 'A-', 'B+') not as a number
            prolog.assertz("student_grade(%s,%s)" % (repr(subj), repr(val)))

    interest = data.get('interest')
    if interest:
        prolog.assertz("student_interest(%s)" % repr(interest.lower()))

    completed = data.get('completed', []) or []
    for c in completed:
        prolog.assertz("completed(%s)" % repr(c))


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/recommend', methods=['POST'])
def recommend():
    payload = request.get_json() or {}
    reset_student_facts()
    assert_student_data(payload)

    results = []
    try:
        # Collect recommendations from Prolog
        for sol in prolog.query("recommend(Course,Reason,Confidence)"):
            course = str(sol['Course'])
            reason = str(sol['Reason'])
            confidence = float(sol['Confidence'])
            results.append({'course': course, 'reason': reason, 'confidence': confidence})

        # Collect risks
        risks = []
        for r in prolog.query("risk(Course,Msg)"):
            risks.append({'course': str(r['Course']), 'message': str(r['Msg'])})

        # Collect explanations (detailed trace) for each recommended course
        explanations = {}
        for sol in prolog.query("explain(Course,Explanation)"):
            c = str(sol['Course'])
            explanations[c] = str(sol['Explanation'])

        # Attach explanation to result entries when available
        for r in results:
            if r['course'] in explanations:
                r['explanation'] = explanations[r['course']]
            else:
                r['explanation'] = r['reason']

        # Sort by confidence desc
        results.sort(key=lambda x: x['confidence'], reverse=True)

        return jsonify({'status': 'ok', 'recommendations': results, 'risks': risks})

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
