document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('studentForm');
  const submitBtn = document.getElementById('submitBtn');
  const sampleBtn = document.getElementById('sampleBtn');
  const sampleWeakBtn = document.getElementById('sampleWeakBtn');
  const recDiv = document.getElementById('recommendations');
  const explanationPanel = document.getElementById('explanationPanel');
  const risksPanel = document.getElementById('risksPanel');

  // Helper function to set select values
  function setSelectValue(id, value) {
    const select = document.getElementById(id);
    if (select && value) {
      select.value = value;
    }
  }

  // Strong student sample (A- average)
  sampleBtn.addEventListener('click', () => {
    document.getElementById('name').value = 'Kamau Wanjiru (A- Student)';
    setSelectValue('english', 'B+');
    setSelectValue('kiswahili', 'B');
    setSelectValue('mathematics', 'A-');
    setSelectValue('physics', 'B+');
    setSelectValue('chemistry', 'B+');
    setSelectValue('biology', 'A-');
    setSelectValue('geography', 'C+');
    setSelectValue('history', 'B-');
    setSelectValue('cre', 'B');
    document.getElementById('interest').value = 'computer_science';
    
    // Clear all checkboxes
    Array.from(document.querySelectorAll('.completed input')).forEach(i => i.checked = false);
    // Set relevant completed prerequisites
    document.querySelector('.completed input[value="programming"]').checked = true;
    document.querySelector('.completed input[value="mathematics"]').checked = true;
  });

  // Weak student sample (C average)
  sampleWeakBtn.addEventListener('click', () => {
    document.getElementById('name').value = 'Otieno Achieng (C Student)';
    setSelectValue('english', 'C+');
    setSelectValue('kiswahili', 'C');
    setSelectValue('mathematics', 'C-');
    setSelectValue('physics', 'D+');
    setSelectValue('chemistry', 'C');
    setSelectValue('biology', 'C+');
    setSelectValue('geography', 'C');
    setSelectValue('history', 'C-');
    setSelectValue('cre', 'C+');
    document.getElementById('interest').value = 'information_technology';
    
    Array.from(document.querySelectorAll('.completed input')).forEach(i => i.checked = false);
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    submitBtn.disabled = true;
    submitBtn.textContent = 'Analyzing KCSE results...';
    recDiv.innerHTML = '';
    explanationPanel.textContent = 'Computing recommendations...';
    risksPanel.textContent = '';

    const payload = { grades: {}, interest: null, completed: [] };
    payload.name = document.getElementById('name').value;
    
    // Get all select values
    const subjects = ['english', 'kiswahili', 'biology', 'cre', 'chemistry', 'physics', 'geography', 'mathematics', 'history'];
    subjects.forEach(s => {
      const select = document.getElementById(s);
      if (select && select.value) {
        payload.grades[s] = select.value;
      }
    });
    
    payload.interest = document.getElementById('interest').value;
    Array.from(document.querySelectorAll('.completed input:checked')).forEach(i => payload.completed.push(i.value));

    try {
      const res = await fetch('/recommend', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      
      if (data.status !== 'ok') {
        throw new Error(data.message || 'Error from server');
      }

      if (data.recommendations.length === 0) {
        recDiv.innerHTML = '<div class="panel">No recommendations returned. Consider improving your KCSE grades.</div>';
      }
      
      data.recommendations.forEach(r => {
        const card = document.createElement('div');
        card.className = 'course-card';
        const left = document.createElement('div');
        left.className = 'meta';
        const confidenceColor = r.confidence >= 70 ? '#6ee7b7' : (r.confidence >= 50 ? '#fbbf24' : '#ef4444');
        left.innerHTML = `
          <div>
            <strong>${r.course}</strong>
            <div style="color:var(--muted);font-size:12px">${r.explanation.substring(0, 100)}...</div>
          </div>
        `;
        const right = document.createElement('div');
        right.innerHTML = `<div class="badge" style="background:${confidenceColor}20; color:${confidenceColor}">${Math.round(r.confidence)}% Match</div>`;
        card.appendChild(left);
        card.appendChild(right);
        card.addEventListener('click', () => {
          explanationPanel.innerHTML = `<strong>${r.course}</strong><br><br>${r.explanation.replace(/;/g, ';<br>')}`;
        });
        recDiv.appendChild(card);
      });

      if (data.risks && data.risks.length) {
        risksPanel.innerHTML = data.risks.map(r => `<div class="risk-item">⚠️ ${r.course}: ${r.message}</div>`).join('');
      } else {
        risksPanel.innerHTML = '✓ No immediate risks detected. Student meets basic requirements.';
      }

    } catch (err) {
      explanationPanel.textContent = 'Error: ' + err.message;
      risksPanel.textContent = 'Could not retrieve recommendations.';
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = 'Get Recommendations';
    }
  });
});