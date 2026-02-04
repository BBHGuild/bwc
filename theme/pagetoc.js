let activeHref = location.href;

function updatePageToc(elem = undefined) {
    let selectedPageTocElem = elem;
    const pagetoc = document.getElementById("pagetoc");

    if (!pagetoc) return;

    function getRect(element) {
        return element.getBoundingClientRect();
    }

    // We've not selected a heading to highlight, and the URL needs updating
    // so we need to find a heading based on the URL
    if (selectedPageTocElem === undefined && location.href !== activeHref) {
        activeHref = location.href;
        for (const pageTocElement of pagetoc.children) {
            if (pageTocElement.href === activeHref) {
                selectedPageTocElem = pageTocElement;
            }
        }
    }

    // We still don't have a selected heading, let's try and find the most
    // suitable heading based on the scroll position
    if (selectedPageTocElem === undefined) {
        const margin = window.innerHeight / 3;

        const headers = document.getElementsByClassName("header");
        for (let i = 0; i < headers.length; i++) {
            const header = headers[i];
            if (selectedPageTocElem === undefined && getRect(header).top >= 0) {
                if (getRect(header).top < margin) {
                    selectedPageTocElem = header;
                } else {
                    selectedPageTocElem = headers[Math.max(0, i - 1)];
                }
            }
            // a very long last section's heading is over the screen
            if (selectedPageTocElem === undefined && i === headers.length - 1) {
                selectedPageTocElem = header;
            }
        }
    }

    // Remove the active flag from all pagetoc elements
    for (const pageTocElement of pagetoc.children) {
        pageTocElement.classList.remove("active");
    }

    // If we have a selected heading, set it to active and scroll to it
    if (selectedPageTocElem !== undefined) {
        for (const pageTocElement of pagetoc.children) {
            if (selectedPageTocElem.href.localeCompare(pageTocElement.href) === 0) {
                pageTocElement.classList.add("active");

                // Ensure the active element is visible by scrolling to it when needed
                const pageTocRect = pagetoc.getBoundingClientRect();
                const elementRect = pageTocElement.getBoundingClientRect();

                // Check if element is above the visible area
                if (elementRect.top < pageTocRect.top) {
                    pagetoc.scrollTop += (elementRect.top - pageTocRect.top - 10);
                }
                // Check if element is below the visible area
                else if (elementRect.bottom > pageTocRect.bottom) {
                    pagetoc.scrollTop += (elementRect.bottom - pageTocRect.bottom + 10);
                }
            }
        }
    }
}

if (document.getElementsByClassName("header").length <= 1) {
    // There's one or less headings, we don't need a page table of contents
    const sidetoc = document.getElementById("sidetoc");
    if (sidetoc) sidetoc.remove();
} else {
    // Populate sidebar on load
    window.addEventListener("load", () => {
        // Function to check if a heading should be excluded from TOC
        function shouldExcludeHeading(header) {
            const headerText = header.textContent || '';
            if (headerText.toLowerCase().includes('table of contents')) {
                return true;
            }
            return false;
        }

        let isFirstHeading = true;
        const headers = document.getElementsByClassName("header");
        const pagetocContainer = document.getElementById("pagetoc");

        if (!pagetocContainer) return;

        for (const header of headers) {
            if (shouldExcludeHeading(header)) {
                continue;
            }

            const link = document.createElement("a");
            link.appendChild(document.createTextNode(header.textContent));
            link.href = header.hash;

            if (isFirstHeading) {
                link.classList.add("pagetoc-title");
                isFirstHeading = false;
            } else {
                link.classList.add("pagetoc-" + header.parentElement.tagName);
            }

            pagetocContainer.appendChild(link);

            link.addEventListener('click', (event) => {
                event.preventDefault();

                const targetId = link.hash.substring(1);
                const targetHeader = document.getElementById(targetId);

                if (targetHeader) {
                    let targetRow = targetHeader.closest('tr');

                    const expandParents = (row) => {
                        if (!row) return;
                        const parentId = row.dataset.bwcParent;
                        if (parentId) {
                            const parentRow = document.querySelector(`.collapsible-header[data-bwc-id="${parentId}"]`);
                            if (parentRow) {
                                expandParents(parentRow);
                                if (!parentRow.classList.contains('expanded')) {
                                    const toggleIcon = parentRow.querySelector('.toggle-icon');
                                    if(toggleIcon) toggleIcon.click(); // Trigger click to handle icon toggle and aria logic
                                }
                            }
                        }
                    };

                    expandParents(targetRow);
                }

                setTimeout(() => {
                    if (targetHeader) {
                        targetHeader.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        history.replaceState(null, null, link.hash);
                    }
                    updatePageToc(link);
                }, 100);
            });
        }

        // --- BWC Table Search / Filter Logic ---
        const bwcTable = document.querySelector('.content table');
        if (bwcTable) {
            // 1. Create Search Input
            const searchContainer = document.createElement('div');
            searchContainer.style.marginBottom = '15px';
            searchContainer.style.display = 'flex';
            searchContainer.style.gap = '10px';

            const searchInput = document.createElement('input');
            searchInput.type = 'text';
            searchInput.placeholder = 'Filter BWC (e.g., "Oracle", "5.1.2")...';
            searchInput.style.padding = '8px';
            searchInput.style.width = '100%';
            searchInput.style.border = '1px solid var(--searchbar-border-color)';
            searchInput.style.borderRadius = '4px';
            searchInput.style.backgroundColor = 'var(--searchbar-bg)';
            searchInput.style.color = 'var(--searchbar-fg)';

            searchContainer.appendChild(searchInput);
            
            // Insert before the table (we will wrap it later, so insert before parent if needed, 
            // but currently table is direct child of content usually)
            bwcTable.parentNode.insertBefore(searchContainer, bwcTable);

            // 2. Filter Function
            searchInput.addEventListener('keyup', (e) => {
                const term = e.target.value.toLowerCase();
                const rows = bwcTable.querySelectorAll('tbody tr');

                if (term.length < 2) {
                    // Reset: Show all, respect original collapsed state? 
                    // Easier to just show everything or revert to default 'expanded' state used in collapsible.js
                    rows.forEach(row => {
                        row.style.display = ''; // Reset inline style
                        // Re-apply correct display based on parent expansion state is complex.
                        // Simplification: logic relies on collapsible.js to handle clicks.
                        // Here we override.
                        
                        // If clean reset is needed, we trigger the 'Expand All' or just show H1s?
                        // Let's just show top levels and expanded children.
                        // Actually, the simplest reset is to remove display:none from match logic
                        // and let the CSS classes/collapsible.js state take over? 
                        // No, collapsible.js uses inline styles too.
                        
                        // Strategy: If filter is cleared, trigger the "Expand All" button logic from collapsible.js
                        // or just leave them open.
                    });
                    // Re-trigger visual update from collapsible state if possible, 
                    // but for now, we just ensure everything is visible or hidden based on class.
                    // A brute force reset:
                    if (term.length === 0) {
                         const toggleBtn = document.querySelector('.toggle-all-btn');
                         if(toggleBtn && toggleBtn.textContent.includes('Collapse')) {
                             // If mode is "Expanded", show all
                             rows.forEach(r => r.style.display = 'table-row');
                         } else {
                             // If mode is "Collapsed", only show H1s?
                             // This is getting tricky. Let's just unhide everything matching the filter.
                         }
                    }
                    return;
                }

                rows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    const isHeader = row.classList.contains('collapsible-header');
                    
                    // Logic: 
                    // 1. If row matches, Show it.
                    // 2. If row matches, Show its PARENTS (recursively).
                    // 3. If row matches AND is a header, Show its CHILDREN? 
                    //    (Optional: maybe just show the header)
                    
                    if (text.includes(term)) {
                        row.style.display = 'table-row';
                        
                        // Expand parents
                        let parentId = row.dataset.bwcParent;
                        while(parentId) {
                            const parentRow = bwcTable.querySelector(`tr[data-bwc-id="${parentId}"]`);
                            if(parentRow) {
                                parentRow.style.display = 'table-row';
                                parentRow.classList.add('expanded'); // Visually expand
                                parentRow.setAttribute('aria-expanded', 'true');
                                parentId = parentRow.dataset.bwcParent;
                            } else {
                                parentId = null;
                            }
                        }
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        }

        // Wrap tables for horizontal scrolling and sticky headers
        const tables = document.querySelectorAll('.content table');
        tables.forEach(table => {
            if (!table.parentElement.classList.contains('table-wrapper')) {
                const wrapper = document.createElement('div');
                wrapper.className = 'table-wrapper';
                table.parentNode.insertBefore(wrapper, table);
                wrapper.appendChild(table);
            }
        });

        updatePageToc();

        // --- Back to Top Button Logic ---
        const backToTopButton = document.getElementById('back-to-top');
        if (backToTopButton) {
            window.addEventListener('scroll', () => {
                if (window.scrollY > 300) {
                    backToTopButton.style.display = 'block';
                } else {
                    backToTopButton.style.display = 'none';
                }
            });

            backToTopButton.addEventListener('click', () => {
                window.scrollTo({ top: 0, behavior: 'smooth' });
            });
        }

        // --- Deep Linking Logic for BWC Table ---
        // If the URL has a hash like #bwc-3-1-1, find that row, expand parents, and scroll.
        if (window.location.hash) {
            const hashId = window.location.hash.substring(1); // remove '#'
            // The IDs in the table are generated by mdbook usually as 'bwc-1-ecosystem...', 
            // but collapsible.js adds data-bwc-id="3-1-1" style attributes or we rely on standard IDs.
            
            // However, our collapsible.js logic generates data attributes.
            // Let's see if we can find a row with data-bwc-id matching the hash or partially matching.
            
            // Actually, the BWC table headers don't have standard IDs by default unless I added them.
            // collapsible.js generates `bwcId` for logic but doesn't set `id` attribute on TR.
            // But the H1/H2/H3 inside usually have IDs generated by mdbook.
            
            // Strategy: 
            // 1. Try to find the element with the ID.
            // 2. If it's inside a table row, traverse up to find the TR.
            // 3. Expand all parents of that TR.
            
            // Note: BWC IDs in table are likely 'bwc-1-ecosystem-...' or similar.
            
            const targetElement = document.getElementById(hashId);
            if (targetElement) {
                const targetRow = targetElement.closest('tr');
                if (targetRow) {
                    // It's inside the table!
                    
                    // Helper to expand a row
                    const expandRow = (row) => {
                       row.classList.add('expanded');
                       row.setAttribute('aria-expanded', 'true');
                       // Show children (visuals handled by collapsible.js click or manual display set)
                       // Since we are not clicking, we must manually show children?
                       // collapsible.js listens for clicks.
                       // We can manually trigger the visual logic or just set display.
                       
                       // We need to show *this row* if it was hidden by a parent.
                       row.style.display = 'table-row';
                    };

                    // Traverse up parents
                    let parentId = targetRow.dataset.bwcParent;
                    while(parentId) {
                        const parentRow = document.querySelector(`tr[data-bwc-id="${parentId}"]`);
                        if(parentRow) {
                            expandRow(parentRow);
                            // Also ensure the *targetRow* (or the intermediate child) is visible
                            // The 'expandRow' on the parent *should* make its direct children visible
                            // based on collapsible.js logic? No, collapsible.js toggles on CLICK.
                            
                            // We need to manually show the children of this parent.
                            const children = document.querySelectorAll(`[data-bwc-parent="${parentId}"]`);
                            children.forEach(child => child.style.display = 'table-row');

                            parentId = parentRow.dataset.bwcParent;
                        } else {
                            break;
                        }
                    }
                    
                    // Finally scroll to it
                    setTimeout(() => {
                        targetRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    }, 500); // Small delay to allow layout to settle
                }
            }
        }

    });

    // Throttle function to improve scroll performance
    function throttle(func, limit) {
        let inThrottle;
        return function() {
            const args = arguments;
            const context = this;
            if (!inThrottle) {
                func.apply(context, args);
                inThrottle = true;
                setTimeout(() => inThrottle = false, limit);
            }
        }
    }

    // Update page table of contents selected heading on scroll
    window.addEventListener("scroll", throttle(() => updatePageToc(), 100));
}