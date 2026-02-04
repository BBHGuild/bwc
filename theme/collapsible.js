document.addEventListener('DOMContentLoaded', function () {
    const table = document.querySelector('.page-wrapper table');
    if (!table) return;

    const rows = Array.from(table.querySelectorAll('tbody tr'));
    let currentH1 = null;
    let currentH2 = null;

    // First pass: Identify rows and establish hierarchy
    rows.forEach(row => {
        const h1 = row.querySelector('h1');
        const h2 = row.querySelector('h2');
        const h3 = row.querySelector('h3');
        let bwcId;

        if (h1) {
            try { bwcId = 'bwc-' + h1.textContent.match(/BWC \d+/)[0].split(' ')[1]; } catch (e) { return; }
            row.classList.add('bwc-h1', 'collapsible-header');
            row.dataset.bwcId = bwcId;
            currentH1 = bwcId;
            currentH2 = null;
        } else if (h2) {
            try { bwcId = 'bwc-' + h2.textContent.match(/BWC [\d\.]+/)[0].split(' ')[1].replace(/\./g, '-'); } catch (e) { return; }
            row.classList.add('bwc-h2', 'collapsible-header');
            row.dataset.bwcId = bwcId;
            if (currentH1) row.dataset.bwcParent = currentH1;
            currentH2 = bwcId;
        } else if (h3) {
            row.classList.add('bwc-h3', 'collapsible-child');
            if (currentH2) row.dataset.bwcParent = currentH2;
            else if (currentH1) row.dataset.bwcParent = currentH1;
        } else if (row.cells.length > 1 && row.cells[1].textContent.trim() === '') {
            // Handle continuation rows for multi-line descriptions under H3s
            row.classList.add('bwc-h3', 'collapsible-child');
            if (currentH2) row.dataset.bwcParent = currentH2;
            else if (currentH1) row.dataset.bwcParent = currentH1;
        }
    });

    // Toggle All Button Logic
    const toggleButton = document.createElement('button');
    toggleButton.textContent = 'Collapse All'; // Default is open, so button allows collapsing
    toggleButton.className = 'toggle-all-btn';
    
    // Insert button before the table
    table.parentElement.insertBefore(toggleButton, table);

    // Function to update visibility based on expanded state
    function updateVisibility(parentId, isExpanded) {
        const children = table.querySelectorAll(`[data-bwc-parent="${parentId}"]`);
        children.forEach(child => {
            if (isExpanded) {
                child.style.display = 'table-row';
                // If this child is also a header and is expanded, ensure its children are shown?
                // Actually, for "Expand All", we want everything open.
                // For "Collapse All", we want everything closed.
                // But for individual toggles, we follow the standard logic.
                
                // However, simply setting display table-row might not be enough if we want recursive "Expand All".
                // If I am showing a child that is an H2, I should check if IT is expanded to show its children.
                // But for "Expand All" button, we force everything.
            } else {
                child.style.display = 'none';
            }
        });
    }

    // Second pass: Add icons and set initial state (DEFAULT OPEN)
    const headers = table.querySelectorAll('.collapsible-header');
    headers.forEach(header => {
        // Find the first cell that actually contains the header tag
        const headerCell = header.querySelector('h1, h2, h3')?.parentElement;
        if (headerCell) {
            headerCell.innerHTML = `<span class="toggle-icon">▶</span>` + headerCell.innerHTML;
        }

        // Set Default State: OPEN
        header.setAttribute('aria-expanded', 'true');
        header.classList.add('expanded');
        // Do NOT hide children by default
    });

    // Ensure all collapsible children are visible by default
    table.querySelectorAll('.collapsible-child').forEach(child => {
        child.style.display = 'table-row';
    });


    toggleButton.addEventListener('click', function() {
        const isCollapsing = toggleButton.textContent.includes('Collapse');
        toggleButton.textContent = isCollapsing ? 'Expand All' : 'Collapse All';

        headers.forEach(header => {
            if (isCollapsing) {
                // COLLAPSE EVERYTHING
                header.classList.remove('expanded');
                header.setAttribute('aria-expanded', 'false');
                
                // If it's H1 or H2, hide its children
                const bwcId = header.dataset.bwcId;
                const children = table.querySelectorAll(`[data-bwc-parent="${bwcId}"]`);
                children.forEach(c => c.style.display = 'none');
            } else {
                // EXPAND EVERYTHING
                header.classList.add('expanded');
                header.setAttribute('aria-expanded', 'true');

                // Show children
                const bwcId = header.dataset.bwcId;
                const children = table.querySelectorAll(`[data-bwc-parent="${bwcId}"]`);
                children.forEach(c => c.style.display = 'table-row');
            }
        });
    });

    // Add the main click listener for individual toggles
    table.addEventListener('click', function (e) {
        const headerRow = e.target.closest('.collapsible-header');
        if (!headerRow) return;

        const bwcId = headerRow.dataset.bwcId;
        const isExpanded = headerRow.classList.contains('expanded'); // State BEFORE toggle click processing? 
        // No, we are about to toggle. If it HAS 'expanded', we are collapsing it.

        headerRow.classList.toggle('expanded');
        const newExpandedState = headerRow.classList.contains('expanded');
        headerRow.setAttribute('aria-expanded', newExpandedState ? 'true' : 'false');

        // Find and toggle visibility of direct children
        const children = table.querySelectorAll(`[data-bwc-parent="${bwcId}"]`);
        children.forEach(child => {
            if (newExpandedState) {
                // We just expanded the parent. Show the child.
                child.style.display = 'table-row';
            } else {
                // We just collapsed the parent. Hide the child.
                child.style.display = 'none';
                
                // If the child is also a header (e.g. H2 inside H1), we should probably collapse it too or just hide it?
                // Standard behavior: Just hide it. State preservation is optional but often preferred.
                // However, to ensure deep collapsing if the user re-opens:
                // If I hide an H2, and then show H1 again, the H2 comes back. 
                // If H2 was expanded, its children should still be visible? 
                // If I hide H2, its children (H3) are NOT hidden by this loop (they are children of H2, not H1).
                // So if H2 is hidden, H3 remains visible? That would be broken visual (floating rows).
                
                // We must recursively hide descendants if we collapse a parent.
                if (child.classList.contains('collapsible-header')) {
                    // It's a header (H2). We should hide ITS children too.
                     const grandChildren = table.querySelectorAll(`[data-bwc-parent="${child.dataset.bwcId}"]`);
                     grandChildren.forEach(gc => gc.style.display = 'none');
                     
                     // Optional: Collapse the child state too so it opens closed next time?
                     // Let's Collapse it to keep state clean.
                     child.classList.remove('expanded');
                     child.setAttribute('aria-expanded', 'false');
                }
            }
        });
    });
});
