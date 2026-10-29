/**
 * DROIDRECOMP — Main Application Logic & Router
 * Modern RecompLauncher Design for Android Recompilations
 */

(function () {
  'use strict';

  // Global State
  let catalogData = [];
  let originsData = [];
  let emulatorsData = [];
  let currentRoute = 'discover';
  let activeOrigin = 'all';
  let filterType = 'all';
  let filterInput = 'all';
  let filterTurnip = false;
  let heroTimer = null;
  let activeHeroIndex = 0;
  let savedGames = JSON.parse(localStorage.getItem('droidrecomp_saved') || '[]');
  let installedGames = JSON.parse(localStorage.getItem('droidrecomp_installed') || 'null');
  let customGames = JSON.parse(localStorage.getItem('droidrecomp_custom_games') || '[]');
  if (installedGames === null) {
    installedGames = ['super-mario-64-ghostship', 'zelda-ocarina-of-time-shipwright', 'another-metroid-2-remake-am2r'];
    localStorage.setItem('droidrecomp_installed', JSON.stringify(installedGames));
  }
  let librarySubTab = 'installed';
  let uiMode = localStorage.getItem('droidrecomp_uimode') || 'auto'; // 'auto', 'desktop', 'mobile'
  let currentTheme = localStorage.getItem('droidrecomp_theme') || 'dark'; // 'dark', 'light', 'oled'

  // DOM Elements
  const viewContent = document.getElementById('view-content');
  const searchModal = document.getElementById('search-modal');
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  const gameModal = document.getElementById('game-modal');
  const modalContent = document.getElementById('modal-content');
  const backdropImg = document.getElementById('backdrop-img');
  const savedCountBadge = document.getElementById('saved-count');
  const uiModeToggle = document.getElementById('ui-mode-toggle');
  const uiModeLabel = document.getElementById('ui-mode-label');
  const themeToggle = document.getElementById('theme-toggle');
  const themeLabel = document.getElementById('theme-label');
  const themeIcon = document.getElementById('theme-icon');

  // Initialize
  async function init() {
    if (searchModal) {
      searchModal.setAttribute('hidden', '');
      searchModal.classList.remove('open');
      searchModal.style.setProperty('display', 'none', 'important');
    }
    if (gameModal) {
      gameModal.setAttribute('hidden', '');
      gameModal.classList.remove('open');
      gameModal.style.setProperty('display', 'none', 'important');
    }

    updateSavedCount();
    applyTheme();
    applyUiMode();
    setupEventListeners();

    if (window.DROIDRECOMP_CATALOG && window.DROIDRECOMP_CATALOG.apps) {
      catalogData = window.DROIDRECOMP_CATALOG.apps;
      originsData = window.DROIDRECOMP_CATALOG.origins || [];
    } else {
      try {
        const resp = await fetch('catalog.json');
        if (!resp.ok) throw new Error('Network error');
        const data = await resp.json();
        catalogData = data.apps || [];
        originsData = data.origins || [];
      } catch (e) {
        console.warn('Loading embedded backup catalog...', e);
        catalogData = getEmbeddedCatalog();
      }
    }

    // Load Emulators Data
    if (window.DROIDRECOMP_EMULATORS && window.DROIDRECOMP_EMULATORS.emulators) {
      emulatorsData = window.DROIDRECOMP_EMULATORS.emulators;
    } else {
      try {
        const eResp = await fetch('emulators.json');
        if (eResp.ok) {
          const eData = await eResp.json();
          emulatorsData = eData.emulators || [];
        }
      } catch (e) {
        console.warn('Failed to fetch emulators.json', e);
      }
    }

    // Merge user custom games into catalog
    mergeCustomGames();

    // Setup custom game modal close handlers
    const customModalClose = document.getElementById('custom-modal-close');
    const customModal = document.getElementById('custom-game-modal');
    if (customModalClose && customModal) {
      customModalClose.addEventListener('click', closeCustomGameModal);
      customModal.addEventListener('click', (e) => {
        if (e.target === customModal) closeCustomGameModal();
      });
    }

    handleRoute();
  }

  function mergeCustomGames() {
    customGames.forEach(cg => {
      const idx = catalogData.findIndex(g => g.id === cg.id);
      if (idx === -1) {
        catalogData.unshift(cg);
      } else {
        catalogData[idx] = cg;
      }
    });
  }

  // Theme Engine (Dark Midnight / Clean Light / AMOLED OLED)
  function applyTheme() {
    document.documentElement.setAttribute('data-theme', currentTheme);
    localStorage.setItem('droidrecomp_theme', currentTheme);

    const icons = {
      dark: '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>', // Moon
      light: '<circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>', // Sun
      oled: '<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>' // Lightning
    };

    const labels = {
      dark: 'Midnight',
      light: 'Light',
      oled: 'OLED'
    };

    if (themeIcon) themeIcon.innerHTML = icons[currentTheme] || icons.dark;
    if (themeLabel) themeLabel.textContent = labels[currentTheme] || 'Theme';
  }

  function toggleTheme() {
    if (currentTheme === 'dark') {
      currentTheme = 'light';
    } else if (currentTheme === 'light') {
      currentTheme = 'oled';
    } else {
      currentTheme = 'dark';
    }
    applyTheme();
  }

  // UI Mode (Mobile vs Desktop override)
  function applyUiMode() {
    if (uiMode === 'mobile') {
      document.body.classList.add('mobile-mode');
      if (uiModeLabel) uiModeLabel.textContent = 'Desktop UI';
    } else if (uiMode === 'desktop') {
      document.body.classList.remove('mobile-mode');
      if (uiModeLabel) uiModeLabel.textContent = 'Mobile UI';
    } else {
      // Auto
      document.body.classList.remove('mobile-mode');
      if (uiModeLabel) uiModeLabel.textContent = window.innerWidth <= 768 ? 'Desktop UI' : 'Mobile UI';
    }
  }

  function toggleUiMode() {
    if (uiMode === 'auto' || uiMode === 'desktop') {
      uiMode = 'mobile';
    } else {
      uiMode = 'desktop';
    }
    localStorage.setItem('droidrecomp_uimode', uiMode);
    applyUiMode();
    renderCurrentView();
  }

  // Routing
  function handleRoute() {
    const hash = window.location.hash.replace('#', '') || 'discover';
    
    // Check if origin filter route e.g. #n64
    const matchedOrigin = ['n64', 'x360', 'xbox', 'gc', 'wii', 'ps1', 'ps2', 'pc_classic', 'snes', 'gba'].find(o => o === hash);
    if (matchedOrigin) {
      currentRoute = 'all';
      activeOrigin = matchedOrigin;
    } else if (hash.startsWith('game/')) {
      const gameId = hash.split('/')[1];
      openGameModal(gameId);
      return;
    } else {
      currentRoute = hash;
    }

    // Update Nav Link Active States
    document.querySelectorAll('[data-nav]').forEach(el => {
      const dnav = el.getAttribute('data-nav');
      const isMatch = (dnav === currentRoute) || 
                      ((currentRoute === 'library' || currentRoute === 'saved') && (dnav === 'library' || dnav === 'saved'));
      el.classList.toggle('on', isMatch);
    });

    // Update Origin Pill States
    document.querySelectorAll('[data-origin]').forEach(el => {
      el.classList.toggle('on', el.getAttribute('data-origin') === activeOrigin);
    });

    renderCurrentView();
  }

  function renderCurrentView() {
    clearInterval(heroTimer);
    window.scrollTo({ top: 0, behavior: 'smooth' });

    switch (currentRoute) {
      case 'all':
        renderAllView();
        break;
      case 'top':
        renderTopView();
        break;
      case 'emulators':
        renderEmulatorsView();
        break;
      case 'handheld':
        renderHandheldView();
        break;
      case 'how':
        renderHowView();
        break;
      case 'library':
      case 'saved':
        renderLibraryView();
        break;
      case 'submit':
        renderSubmitView();
        break;
      case 'discover':
      default:
        renderDiscoverView();
        break;
    }
  }

  // =========================================================================
  // VIEW: DISCOVER (HOME)
  // =========================================================================
  function renderDiscoverView() {
    // Top featured games for carousel
    const featuredGames = [
      'zelda-64-recomp-android',
      'forza-horizon',
      'banjo-kazooie-recomp',
      'sonic-unleashed-recompiled',
      'dusklight',
      'diablo-hellfire',
      'super-mario-64',
      'balatro'
    ].map(id => catalogData.find(g => g.id.includes(id) || g.id === id)).filter(Boolean);

    // If less than 4, fallback to first few
    const slides = featuredGames.length >= 3 ? featuredGames : catalogData.slice(0, 5);

    // Filter Top Ranked (by downloads & stars)
    const topRanked = [...catalogData].sort((a, b) => (b.downloads || 0) - (a.downloads || 0)).slice(0, 10);
    // Filter Handheld Verified
    const handheldGames = catalogData.filter(g => g.input && g.input.controller_recommended || g.input && g.input.controller).slice(0, 10);
    // Filter Classic PC & Source Ports
    const pcPorts = catalogData.filter(g => g.origin === 'pc_classic').slice(0, 10);
    // Filter N64 Recomps
    const n64Games = catalogData.filter(g => g.origin === 'n64').slice(0, 10);

    viewContent.innerHTML = `
      <!-- HERO CAROUSEL -->
      <section class="hero-slider" id="hero-slider">
        ${slides.map((game, i) => `
          <div class="hero-slide ${i === 0 ? 'active' : ''}" data-index="${i}">
            <div class="hero-bg" style="background-image: url('${game.hero || game.cover}');"></div>
            <div class="hero-gradient"></div>
            <div class="hero-content">
              <div class="hero-tags">
                <span class="tag tag-origin">${originLabel(game.origin)}</span>
                <span class="tag">${game.type}</span>
                ${game.graphics.turnip_recommended ? `<span class="tag tag-turnip">⚡ Turnip Rec.</span>` : ''}
                ${game.input.touch ? `<span class="tag tag-touch">Touch Ready</span>` : ''}
                <span class="tag">${game.graphics.fps_target || 60} FPS</span>
              </div>
              <h1 class="hero-title">${escapeHtml(game.name)}</h1>
              <p class="hero-lead">${escapeHtml(game.blurb || '')}</p>
              <div class="hero-actions">
                <button type="button" class="btn btn-primary" onclick="window.DroidRecomp.openModal('${game.id}')">
                  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                  <span>Download & Details</span>
                </button>
                ${game.obtainium_url ? `
                  <a class="btn btn-secondary" href="${game.obtainium_url}" title="Open in Obtainium">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
                    <span>Add to Obtainium</span>
                  </a>
                ` : ''}
              </div>
            </div>
          </div>
        `).join('')}
        <div class="hero-dots">
          ${slides.map((_, i) => `<span class="hero-dot ${i === 0 ? 'active' : ''}" data-dot="${i}"></span>`).join('')}
        </div>
      </section>

      <!-- TOP RANKED HORIZONTAL ROW -->
      <section class="section-row">
        <div class="section-head">
          <h2 class="section-title">
            <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" color="#34F2E8"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
            <span>Top Community Recomps</span>
          </h2>
          <a class="section-link" href="#top">View full charts &rarr;</a>
        </div>
        <div class="rowscroll">
          ${topRanked.map((game, idx) => posterCard(game, idx + 1)).join('')}
        </div>
      </section>

      <!-- NINTENDO 64 RECOMPS ROW -->
      <section class="section-row" style="margin-top: 36px;">
        <div class="section-head">
          <h2 class="section-title">
            <span>Nintendo 64 Recompilations</span>
          </h2>
          <a class="section-link" href="#all" onclick="window.DroidRecomp.setOrigin('n64')">See all N64 &rarr;</a>
        </div>
        <div class="rowscroll">
          ${n64Games.map((game, idx) => posterCard(game)).join('')}
        </div>
      </section>

      <!-- HANDHELD OPTIMIZED ROW -->
      <section class="section-row" style="margin-top: 36px;">
        <div class="section-head">
          <h2 class="section-title">
            <span>Handheld Console Verified</span>
          </h2>
          <span style="font-size: 0.85rem; color: var(--muted);">Retroid Pocket • AYN Odin • G Cloud</span>
        </div>
        <div class="rowscroll">
          ${handheldGames.map(game => posterCard(game)).join('')}
        </div>
      </section>

      <!-- CLASSIC PC ENGINE PORTS ROW -->
      <section class="section-row" style="margin-top: 36px;">
        <div class="section-head">
          <h2 class="section-title">
            <span>Classic PC & Engine Re-implementations</span>
          </h2>
          <a class="section-link" href="#all" onclick="window.DroidRecomp.setOrigin('pc_classic')">Browse PC &rarr;</a>
        </div>
        <div class="rowscroll">
          ${pcPorts.map(game => posterCard(game)).join('')}
        </div>
      </section>

      <!-- LEGAL & ROM DISCLAIMER BOX -->
      <div class="disc-note">
        <span class="kicker">Strict Bring-Your-Own-ROM Policy</span>
        <p>DroidRecomp indexes only open-source native Android game recompilations, source decompilations, and their community launchers straight from developers' public repositories. <strong>Zero copyrighted ROMs, ISOs, or proprietary assets are hosted on this platform.</strong> Every game requires you to supply your own legally owned game files.</p>
      </div>
    `;

    // Start Hero Carousel Timer
    startHeroTimer(slides);
    setAmbientBackdrop(slides[0]?.hero || slides[0]?.cover);
  }

  // Hero Timer
  function startHeroTimer(slides) {
    if (!slides.length) return;
    activeHeroIndex = 0;
    heroTimer = setInterval(() => {
      activeHeroIndex = (activeHeroIndex + 1) % slides.length;
      updateHeroSlide(slides);
    }, 7000);

    // Setup Dot clicks
    document.querySelectorAll('[data-dot]').forEach(dot => {
      dot.addEventListener('click', () => {
        clearInterval(heroTimer);
        activeHeroIndex = parseInt(dot.getAttribute('data-dot'), 10);
        updateHeroSlide(slides);
      });
    });
  }

  function updateHeroSlide(slides) {
    const slideEls = document.querySelectorAll('.hero-slide');
    const dotEls = document.querySelectorAll('.hero-dot');
    slideEls.forEach((s, idx) => s.classList.toggle('active', idx === activeHeroIndex));
    dotEls.forEach((d, idx) => d.classList.toggle('active', idx === activeHeroIndex));
    setAmbientBackdrop(slides[activeHeroIndex]?.hero || slides[activeHeroIndex]?.cover);
  }

  // =========================================================================
  // VIEW: ALL RECOMPS (CATALOG GRID + FILTERS)
  // =========================================================================
  function renderAllView() {
    let filtered = catalogData;

    // Origin Filter
    if (activeOrigin !== 'all') {
      filtered = filtered.filter(g => g.origin === activeOrigin);
    }

    // Port Type Filter
    if (filterType !== 'all') {
      filtered = filtered.filter(g => g.type === filterType);
    }

    // Input Filter
    if (filterInput === 'touch') {
      filtered = filtered.filter(g => g.input && g.input.touch);
    } else if (filterInput === 'controller') {
      filtered = filtered.filter(g => g.input && g.input.controller_recommended);
    }

    // Turnip Driver Filter
    if (filterTurnip) {
      filtered = filtered.filter(g => g.graphics && g.graphics.turnip_recommended);
    }

    viewContent.innerHTML = `
      <div style="margin-bottom: 24px;">
        <h1 style="font-family: var(--font-display); font-size: 2rem; font-weight: 800; margin-bottom: 6px;">All Android Recomps</h1>
        <p style="color: var(--muted); font-size: 0.95rem;">Showing ${filtered.length} verified native ports & static recompilations for Android devices.</p>
      </div>

      <!-- QUAD-FILTER BAR -->
      <div class="filter-bar">
        <div class="filter-group">
          <span class="filter-label">System:</span>
          <select class="filter-select" id="filter-origin-select" onchange="window.DroidRecomp.setOrigin(this.value)">
            <option value="all" ${activeOrigin === 'all' ? 'selected' : ''}>All Systems (133)</option>
            <option value="n64" ${activeOrigin === 'n64' ? 'selected' : ''}>Nintendo 64</option>
            <option value="x360" ${activeOrigin === 'x360' ? 'selected' : ''}>Xbox 360</option>
            <option value="xbox" ${activeOrigin === 'xbox' ? 'selected' : ''}>Xbox</option>
            <option value="gc" ${activeOrigin === 'gc' ? 'selected' : ''}>GameCube</option>
            <option value="wii" ${activeOrigin === 'wii' ? 'selected' : ''}>Wii</option>
            <option value="ps1" ${activeOrigin === 'ps1' ? 'selected' : ''}>PlayStation 1</option>
            <option value="ps2" ${activeOrigin === 'ps2' ? 'selected' : ''}>PlayStation 2</option>
            <option value="pc_classic" ${activeOrigin === 'pc_classic' ? 'selected' : ''}>Classic PC & Engines</option>
          </select>

          <span class="filter-label">Architecture:</span>
          <select class="filter-select" id="filter-type-select" onchange="window.DroidRecomp.setType(this.value)">
            <option value="all" ${filterType === 'all' ? 'selected' : ''}>All Types</option>
            <option value="Static Recomp" ${filterType === 'Static Recomp' ? 'selected' : ''}>Static Recompilation</option>
            <option value="Decompilation" ${filterType === 'Decompilation' ? 'selected' : ''}>Source Decompilation</option>
            <option value="Native Engine Port" ${filterType === 'Native Engine Port' ? 'selected' : ''}>Engine Re-implementation</option>
          </select>

          <span class="filter-label">Input:</span>
          <select class="filter-select" id="filter-input-select" onchange="window.DroidRecomp.setInput(this.value)">
            <option value="all" ${filterInput === 'all' ? 'selected' : ''}>All Controls</option>
            <option value="touch" ${filterInput === 'touch' ? 'selected' : ''}>Touch Overlay Ready</option>
            <option value="controller" ${filterInput === 'controller' ? 'selected' : ''}>Gamepad Recommended</option>
          </select>
        </div>

        <div class="filter-group">
          <button type="button" class="filter-toggle ${filterTurnip ? 'on' : ''}" onclick="window.DroidRecomp.toggleTurnip()">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
            <span>Turnip Driver Tested</span>
          </button>
        </div>
      </div>

      <!-- MAIN GAMES GRID -->
      <div class="games-grid">
        ${filtered.map(game => gameCard(game)).join('')}
      </div>

      ${filtered.length === 0 ? `
        <div style="text-align: center; padding: 60px 20px; color: var(--muted);">
          <h3>No matching recompilations found</h3>
          <p>Try resetting filters or picking another console system.</p>
          <button class="btn btn-secondary" style="margin-top: 14px;" onclick="window.DroidRecomp.resetFilters()">Reset Filters</button>
        </div>
      ` : ''}
    `;
  }

  // =========================================================================
  // VIEW: TOP CHARTS
  // =========================================================================
  function renderTopView() {
    const sorted = [...catalogData].sort((a, b) => (b.downloads || 0) - (a.downloads || 0));

    viewContent.innerHTML = `
      <div style="margin-bottom: 24px;">
        <h1 style="font-family: var(--font-display); font-size: 2rem; font-weight: 800; margin-bottom: 6px;">Top Charts & Rankings</h1>
        <p style="color: var(--muted); font-size: 0.95rem;">Most downloaded and highest-starred native Android recompilations.</p>
      </div>

      <div class="games-grid">
        ${sorted.map((game, i) => gameCard(game, i + 1)).join('')}
      </div>
    `;
  }

  // =========================================================================
  // VIEW: HANDHELD OPTIMIZED
  // =========================================================================
  function renderHandheldView() {
    const handheld = catalogData.filter(g => g.input && g.input.controller);

    viewContent.innerHTML = `
      <div style="margin-bottom: 24px;">
        <span class="badge-android">Handheld Verified</span>
        <h1 style="font-family: var(--font-display); font-size: 2rem; font-weight: 800; margin-top: 8px; margin-bottom: 6px;">Dedicated Handheld Gaming Library</h1>
        <p style="color: var(--muted); font-size: 0.95rem;">Curated collection confirmed to work out-of-the-box with physical controls on Retroid Pocket 4/5, AYN Odin 2, AYANEO Pocket, Logitech G Cloud, and Razer Edge.</p>
      </div>

      <div class="games-grid">
        ${handheld.map(game => gameCard(game)).join('')}
      </div>
    `;
  }

  // =========================================================================
  // VIEW: LIBRARY & GAME LAUNCHER
  // =========================================================================
  const KNOWN_PACKAGES = {
    'super-mario-64-ghostship': 'com.n64.sm64',
    'zelda-ocarina-of-time-shipwright': 'com.soh.android',
    '2-ship-2-harkinian-2s2h': 'com.soh.twoship',
    'another-metroid-2-remake-am2r': 'com.am2r.android',
    'morrowind-openmw': 'org.libsdl.app',
    'diablo-1-devilutionx': 'org.diasurgical.devilutionx',
    'sonic-mania-decompilation-android': 'org.sonicteam.sonicmania',
    'sonic-1-forever': 'com.sonic1.forever',
    'half-life-amp-goldsrc-games': 'in.celest.xash3d.hl',
    'half-life-2-amp-portal': 'org.srceng.source',
    'fallout-1': 'com.alexander.fo1',
    'fallout-2': 'com.alexander.fo2',
    'celeste-classic-android': 'com.celeste.android',
    'hollow-knight-mobile': 'com.teamcherry.hollowknight',
    'balatro-mobile': 'com.localthunk.balatro',
    'pizza-tower-android': 'com.tourdepizza.pizzatower',
    'crash-team-racing': 'com.recomp.ctr',
    'silent-hill': 'com.recomp.silenthill',
    'halo-combat-evolved': 'com.recomp.halo',
    'resident-evil-4': 'com.recomp.re4',
    'metroid-prime': 'com.recomp.metroidprime',
    'banjo-kazooie-recomp': 'com.recomp.bk',
    'perfect-dark-recomp': 'com.recomp.perfectdark'
  };

  function getPackageName(game) {
    if (!game) return 'com.recomp.app';
    if (game.package_name) return game.package_name;
    if (KNOWN_PACKAGES[game.id]) return KNOWN_PACKAGES[game.id];
    const custom = localStorage.getItem('pkg_' + game.id);
    if (custom) return custom;
    return 'com.recomp.' + game.id.replace(/[^a-zA-Z0-9]/g, '_');
  }

  function launchGame(id, event) {
    if (event) event.stopPropagation();
    const game = catalogData.find(g => g.id === id);
    if (!game) return;
    const pkg = getPackageName(game);

    showToast(`🚀 Launching ${game.name}...`);

    // On Android mobile devices, trigger intent URL
    const intentUri = `intent:#Intent;package=${pkg};category=android.intent.category.LAUNCHER;action=android.intent.action.MAIN;end`;
    
    // Attempt launch via invisible frame
    const launchFrame = document.createElement('iframe');
    launchFrame.style.display = 'none';
    launchFrame.src = intentUri;
    document.body.appendChild(launchFrame);
    setTimeout(() => {
      if (launchFrame.parentNode) launchFrame.parentNode.removeChild(launchFrame);
    }, 1000);

    // Fallback direct redirection
    setTimeout(() => {
      window.location.href = intentUri;
    }, 120);
  }

  function toggleInstalled(id, event) {
    if (event) event.stopPropagation();
    const idx = installedGames.indexOf(id);
    if (idx >= 0) {
      installedGames.splice(idx, 1);
      showToast('Removed from Installed Games');
    } else {
      installedGames.push(id);
      showToast('Added to Installed Games');
    }
    localStorage.setItem('droidrecomp_installed', JSON.stringify(installedGames));
    updateSavedCount();
    if (currentRoute === 'library' || currentRoute === 'saved') {
      renderLibraryView();
    }
    if (gameModal && !gameModal.hasAttribute('hidden')) {
      const g = catalogData.find(item => item.id === id);
      if (g) openModal(id);
    }
  }

  function setLibraryTab(tab) {
    librarySubTab = tab;
    renderLibraryView();
  }

  function showToast(message) {
    const existing = document.getElementById('dr-toast');
    if (existing) existing.remove();

    const toast = document.createElement('div');
    toast.id = 'dr-toast';
    toast.className = 'toast-container';
    toast.innerHTML = `<span>${escapeHtml(message)}</span>`;
    document.body.appendChild(toast);

    setTimeout(() => {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, 3200);
  }

  // =========================================================================
  // VIEW: ANDROID EMULATORS HUB
  // =========================================================================
  let emulatorFilter = 'all';
  let emulatorSearchQuery = '';

  function renderEmulatorsView() {
    let list = [...emulatorsData];

    // Filter by System / Category / Price
    if (emulatorFilter !== 'all') {
      if (emulatorFilter === 'free') {
        list = list.filter(e => !e.is_paid);
      } else if (emulatorFilter === 'paid') {
        list = list.filter(e => e.is_paid);
      } else if (emulatorFilter === 'psp_vita') {
        list = list.filter(e => e.system === 'psp' || e.system === 'ps_vita' || e.system === 'psp_vita');
      } else if (emulatorFilter === 'n64') {
        list = list.filter(e => e.system === 'n64');
      } else if (emulatorFilter === 'gba') {
        list = list.filter(e => e.system === 'gba' || e.system === 'gbc');
      } else if (emulatorFilter === 'snes') {
        list = list.filter(e => e.system === 'snes');
      } else if (emulatorFilter === 'engines_mobile') {
        list = list.filter(e => e.system === 'engines_mobile');
      } else if (emulatorFilter === 'dc_saturn') {
        list = list.filter(e => e.system === 'dc_saturn');
      } else if (emulatorFilter === 'multi') {
        list = list.filter(e => e.system === 'multi');
      } else if (emulatorFilter === 'drivers') {
        list = list.filter(e => e.system === 'drivers');
      } else {
        list = list.filter(e => e.system === emulatorFilter);
      }
    }

    // Filter by Search Query
    if (emulatorSearchQuery.trim()) {
      const q = emulatorSearchQuery.trim().toLowerCase();
      list = list.filter(e => 
        e.name.toLowerCase().includes(q) ||
        e.system_name.toLowerCase().includes(q) ||
        e.developer.toLowerCase().includes(q) ||
        (e.description && e.description.toLowerCase().includes(q)) ||
        (e.features && e.features.some(f => f.toLowerCase().includes(q))) ||
        (e.license && e.license.toLowerCase().includes(q)) ||
        (e.price && e.price.toLowerCase().includes(q))
      );
    }

    const categories = [
      { id: 'all', label: `All Emulators (${emulatorsData.length})` },
      { id: 'free', label: '🎁 Free Only' },
      { id: 'paid', label: '💎 Paid / Pro' },
      { id: 'ps2', label: 'PlayStation 2' },
      { id: 'switch', label: 'Nintendo Switch' },
      { id: 'pc_win', label: 'PC & Translation' },
      { id: 'engines_mobile', label: 'Engines & Mobile (JoiPlay/iOS)' },
      { id: 'gc_wii', label: 'GameCube & Wii' },
      { id: '3ds', label: 'Nintendo 3DS' },
      { id: 'nds', label: 'Nintendo DS' },
      { id: 'n64', label: 'Nintendo 64' },
      { id: 'gba', label: 'Game Boy Advance & Color' },
      { id: 'snes', label: 'Super Nintendo (SNES)' },
      { id: 'psp_vita', label: 'PSP & Vita' },
      { id: 'ps1', label: 'PlayStation 1' },
      { id: 'dc_saturn', label: 'Dreamcast & Saturn' },
      { id: 'multi', label: 'Frontends & Multi' },
      { id: 'drivers', label: '⚡ Turnip Drivers' }
    ];

    viewContent.innerHTML = `
      <section class="emulators-header">
        <span class="emulators-badge">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>
          Android Emulation Suite
        </span>
        <h1 class="emulators-title">Android Emulators Hub</h1>
        <p class="emulators-subtitle">
          The curated directory of verified, high-performance console and PC emulators for Android. Compare graphics backends, download official release APKs, sync with Obtainium, and install custom Mesa Turnip Adreno GPU drivers.
        </p>

        <div class="emulators-toolbar">
          <div class="emulators-search-box">
            <svg class="emulators-search-icon" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="6.5"/><path d="m16 16 4.5 4.5"/></svg>
            <input type="search" id="emu-search-input" placeholder="Search emulators, systems, drivers..." value="${escapeHtml(emulatorSearchQuery)}" oninput="window.DroidRecomp.searchEmulators(this.value)">
          </div>

          <div class="emulators-filter-pills">
            ${categories.map(c => `
              <button type="button" class="emulators-filter-pill ${emulatorFilter === c.id ? 'active' : ''}" onclick="window.DroidRecomp.setEmulatorFilter('${c.id}')">
                ${c.label}
              </button>
            `).join('')}
          </div>
        </div>
      </section>

      ${list.length === 0 ? `
        <div style="text-align: center; padding: 60px 20px; color: var(--muted);">
          <svg viewBox="0 0 24 24" width="56" height="56" fill="none" stroke="currentColor" stroke-width="1.5" style="opacity: 0.5; margin-bottom: 16px;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
          <h3 style="font-size: 1.2rem; color: var(--frost); margin-bottom: 8px;">No Emulators Found</h3>
          <p>No results matched your search or category filter.</p>
          <button type="button" class="btn btn-secondary" style="margin-top: 14px;" onclick="window.DroidRecomp.setEmulatorFilter('all')">Reset Filter</button>
        </div>
      ` : `
        <div class="emulators-grid">
          ${list.map(emu => `
            <div class="emulator-card">
              <div class="emulator-card-head">
                <div class="emulator-icon-wrap">
                  <img src="${emu.icon}" alt="${escapeHtml(emu.name)}" loading="lazy" onerror="this.src='favicon.svg';">
                </div>
                <div class="emulator-meta">
                  <div class="emulator-name-row">
                    <span class="emulator-name">${escapeHtml(emu.name)}</span>
                    <span class="emulator-version-chip">${escapeHtml(emu.version)}</span>
                    ${emu.is_paid 
                      ? `<span class="tag-paid">${escapeHtml(emu.price || 'Paid')}</span>` 
                      : `<span class="tag-free">Free</span>`}
                  </div>
                  <div class="emulator-system-label">${escapeHtml(emu.system_name)}</div>
                  <div class="emulator-author">by ${escapeHtml(emu.developer)}</div>
                </div>
              </div>

              <div class="emulator-tags" style="display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 12px;">
                <span class="tag tag-origin">${escapeHtml(emu.category)}</span>
                <span class="tag">${escapeHtml(emu.graphics_backend.split('/')[0].trim())}</span>
                <span class="tag ${emu.is_paid ? 'tag-price-paid' : 'tag-price-free'}">${escapeHtml(emu.license || (emu.is_paid ? 'Paid' : 'Free'))}</span>
                ${emu.turnip_recommended ? `<span class="tag tag-turnip">⚡ Turnip Rec.</span>` : ''}
              </div>

              <p class="emulator-desc">${escapeHtml(emu.description)}</p>

              <div class="emulator-features">
                ${emu.features.slice(0, 4).map(f => `
                  <div class="emulator-feature-item">
                    <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    <span>${escapeHtml(f)}</span>
                  </div>
                `).join('')}
              </div>

              <div class="emulator-specs-row">
                <span><strong>Min OS:</strong> ${escapeHtml(emu.min_android)}</span>
                <span><strong>Graphics:</strong> ${escapeHtml(emu.graphics_backend)}</span>
              </div>

              <div class="emulator-actions">
                ${emu.apk_url ? `
                  <a class="btn-emu-apk ${emu.is_paid ? 'btn-emu-paid' : ''}" href="${emu.apk_url}" target="_blank" rel="noopener" title="${emu.is_paid ? 'Get from Store / Official Site' : 'Download Release APK'}">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    <span>${emu.is_paid ? (emu.apk_url.includes('google.com') ? 'Google Play' : 'Get App') : 'Download APK'}</span>
                  </a>
                ` : ''}
                ${emu.obtainium_url ? `
                  <a class="btn-emu-obtainium" href="${emu.obtainium_url}" title="Add to Obtainium Updater">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
                    <span>Obtainium</span>
                  </a>
                ` : ''}
                ${emu.repo_url ? `
                  <a class="btn-emu-repo" href="${emu.repo_url}" target="_blank" rel="noopener" title="View Source & Releases">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                  </a>
                ` : ''}
              </div>
            </div>
          `).join('')}
        </div>
      `}
    `;
  }

  function renderLibraryView() {
    mergeCustomGames();
    const installedList = catalogData.filter(g => installedGames.includes(g.id));
    const savedList = catalogData.filter(g => savedGames.includes(g.id));

    viewContent.innerHTML = `
      <div class="library-header">
        <div>
          <h1 style="font-family: var(--font-display); font-size: 2rem; font-weight: 800; margin-bottom: 6px;">My Game Library</h1>
          <p style="color: var(--muted); font-size: 0.95rem;">Launch your installed recompilations directly or add your own custom unlisted games.</p>
        </div>

        <div style="display: flex; gap: 10px; flex-wrap: wrap; align-items: center;">
          <div class="library-tabs-nav">
            <button type="button" class="library-tab-btn ${librarySubTab === 'installed' ? 'active' : ''}" onclick="window.DroidRecomp.setLibraryTab('installed')">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="6" width="20" height="12" rx="3"/><circle cx="8" cy="12" r="1.5"/><circle cx="16" cy="12" r="1.5"/><path d="M12 9v6M9 12h6"/></svg>
              <span>Installed</span>
              <span class="library-tab-badge">${installedList.length}</span>
            </button>
            <button type="button" class="library-tab-btn ${librarySubTab === 'bookmarks' ? 'active' : ''}" onclick="window.DroidRecomp.setLibraryTab('bookmarks')">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
              <span>Saved</span>
              <span class="library-tab-badge">${savedList.length}</span>
            </button>
          </div>

          <button type="button" class="btn btn-primary" onclick="window.DroidRecomp.openAddCustomGameModal()" title="Add Custom / Unlisted Game">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            <span>Add Custom Game</span>
          </button>

          <a class="btn btn-secondary" href="#submit" title="Submit to Official Master Catalog">
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <span>Submit to Catalog</span>
          </a>
        </div>
      </div>

      ${librarySubTab === 'installed' ? `
        ${installedList.length > 0 ? `
          <div class="library-installed-grid">
            ${installedList.map(game => `
              <div class="installed-card" onclick="window.DroidRecomp.openModal('${game.id}')">
                <div class="installed-card-top">
                  <img class="installed-card-cover" src="${game.cover}" alt="${escapeHtml(game.name)}" loading="lazy" referrerpolicy="no-referrer">
                  <div class="installed-card-body">
                    <div>
                      <h3 class="installed-card-title">${escapeHtml(game.name)}</h3>
                      <div class="installed-badge-row">
                        <span class="badge-installed">✓ Installed</span>
                        ${game.isCustom ? '<span class="badge-custom">Custom Sideload</span>' : ''}
                        <span class="tag tag-origin" style="font-size: 0.65rem; padding: 1px 6px;">${originLabel(game.origin)}</span>
                      </div>
                      <div class="badge-package">${getPackageName(game)}</div>
                    </div>
                  </div>
                </div>
                <div class="installed-card-actions">
                  <button type="button" class="btn-launch-game" onclick="window.DroidRecomp.launchGame('${game.id}', event)">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                    <span>LAUNCH GAME</span>
                  </button>
                  ${game.isCustom ? `
                    <button type="button" class="btn-remove-installed" title="Delete Custom Game" onclick="window.DroidRecomp.deleteCustomGame('${game.id}', event)">
                      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                    </button>
                  ` : `
                    <button type="button" class="btn-remove-installed" title="Remove from Installed" onclick="window.DroidRecomp.toggleInstalled('${game.id}', event)">
                      <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                    </button>
                  `}
                </div>
              </div>
            `).join('')}
          </div>
        ` : `
          <div style="text-align: center; padding: 70px 20px; background: var(--glass); border-radius: var(--radius-lg); border: 1px solid var(--line);">
            <svg viewBox="0 0 24 24" width="48" height="48" stroke="currentColor" fill="none" stroke-width="1.5" style="color: var(--muted); margin-bottom: 16px;"><rect x="2" y="6" width="20" height="12" rx="3"/><circle cx="8" cy="12" r="1.5"/><circle cx="16" cy="12" r="1.5"/><path d="M12 9v6M9 12h6"/></svg>
            <h3>No Installed Games Added</h3>
            <p style="color: var(--muted); margin-top: 6px; max-width: 440px; margin-left: auto; margin-right: auto;">Open any game from the catalog and tap <strong>"+ Mark as Installed"</strong> to launch it directly from this library.</p>
            <a class="btn btn-primary" href="#discover" style="margin-top: 18px;">Browse Recomps Catalog</a>
          </div>
        `}
      ` : `
        ${savedList.length > 0 ? `
          <div style="margin-bottom: 20px;">
            <button type="button" class="btn btn-secondary" onclick="window.DroidRecomp.exportSavedToObtainium()">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
              <span>Export Saved as Obtainium JSON</span>
            </button>
          </div>
          <div class="games-grid">
            ${savedList.map(game => gameCard(game)).join('')}
          </div>
        ` : `
          <div style="text-align: center; padding: 70px 20px; background: var(--glass); border-radius: var(--radius-lg); border: 1px solid var(--line);">
            <svg viewBox="0 0 24 24" width="48" height="48" stroke="currentColor" fill="none" stroke-width="1.5" style="color: var(--muted); margin-bottom: 16px;"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            <h3>No Saved Bookmarks</h3>
            <p style="color: var(--muted); margin-top: 6px;">Bookmark games to sync them via Obtainium or track updates.</p>
            <a class="btn btn-primary" href="#all" style="margin-top: 18px;">Explore All Recomps</a>
          </div>
        `}
      `}
    `;
  }

  // =========================================================================
  // VIEW: SETUP & HOW IT WORKS
  // =========================================================================
  function renderHowView() {
    viewContent.innerHTML = `
      <div style="max-width: 860px; margin: 0 auto;">
        <h1 style="font-family: var(--font-display); font-size: 2.4rem; font-weight: 900; margin-bottom: 12px;">How Android Recomps Work</h1>
        <p style="font-size: 1.1rem; color: var(--muted); line-height: 1.6; margin-bottom: 36px;">Static recompilation and native source ports translate original console machine code into native ARM64 instructions, achieving flawless 60–120 FPS performance with zero emulator overhead.</p>

        <div style="display: flex; flex-direction: column; gap: 24px; margin-bottom: 40px;">
          <div class="disc-note" style="margin: 0;">
            <span class="kicker">Step 1 — Download the APK or Sync via Obtainium</span>
            <p>Grab the compiled <code>arm64-v8a.apk</code> directly from the developer's GitHub Releases tab. For automated background updates, use Obtainium with our one-click sync buttons.</p>
          </div>

          <div class="disc-note" style="margin: 0;">
            <span class="kicker">Step 2 — Provide Your Legally Owned Game Files</span>
            <p>Because recompilations contain no copyrighted Nintendo, Sony, or Xbox assets, you must supply your own dumped ROM (e.g. <code>.z64</code>, <code>.iso</code>) or PC data files (e.g. <code>DIABDAT.MPQ</code>, <code>Data Files</code>). The port will extract audio, 3D meshes, and textures on your device.</p>
          </div>

          <div class="disc-note" style="margin: 0;">
            <span class="kicker">Step 3 — Scoped Storage & Asset Placement</span>
            <p>On Android 11 through 14+, file access is protected. Most recomps use the Android Storage Access Framework (SAF) folder picker on first boot. Point it to your files folder or place them in <code>/sdcard/Android/data/{package_name}/files/</code> using an external file manager like Shizuku or ZArchiver.</p>
          </div>
        </div>

        <!-- CLIENT-SIDE ROM HASH TESTER -->
        <div style="background: var(--glass); border: 1px solid var(--line); border-radius: var(--radius-lg); padding: 28px;">
          <h3 style="font-family: var(--font-display); font-size: 1.3rem; font-weight: 800; margin-bottom: 8px;">In-Browser ROM Checksum Tester</h3>
          <p style="font-size: 0.9rem; color: var(--muted); margin-bottom: 16px;">Verify that your N64 or console ROM is the exact required USA v1.0 version before copying it to your phone. <em>(100% private: processing is done locally in your browser with Web Crypto API; no file is uploaded).</em></p>
          
          <div class="rom-checker-box">
            <input type="file" id="rom-file-input" style="display: none;" onchange="window.DroidRecomp.verifyRomFile(this.files[0])">
            <div class="rom-drop-zone" onclick="document.getElementById('rom-file-input').click()">
              <svg viewBox="0 0 24 24" width="36" height="36" fill="none" stroke="currentColor" stroke-width="1.8" style="color: var(--cyan); margin-bottom: 8px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
              <div style="font-weight: 600;">Click to select ROM (.z64, .iso, .bin, .dat)</div>
              <div style="font-size: 0.8rem; color: var(--muted); margin-top: 4px;">Local SHA-1 hash calculation</div>
            </div>
            <div id="rom-hash-output" style="margin-top: 14px; font-size: 0.88rem; font-family: monospace; display: none;"></div>
          </div>
        </div>
      </div>
    `;
  }

  // =========================================================================
  // VIEW: SUBMIT PORT
  // =========================================================================
  // =========================================================================
  // CUSTOM GAME / UNLISTED PORT MODAL WORKFLOW
  // =========================================================================
  function openAddCustomGameModal() {
    const customModal = document.getElementById('custom-game-modal');
    const customModalContent = document.getElementById('custom-modal-content');
    if (!customModal || !customModalContent) return;

    customModalContent.innerHTML = `
      <div style="padding: 10px 0;">
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
          <div style="width: 36px; height: 36px; border-radius: 8px; background: rgba(52, 242, 232, 0.15); display: flex; align-items: center; justify-content: center; color: var(--brand);">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
          </div>
          <div>
            <h2 style="font-size: 1.35rem; font-weight: 800; color: var(--frost); margin: 0;">Add Custom / Unlisted Game</h2>
            <p style="font-size: 0.8rem; color: var(--muted); margin: 0;">Add any sideloaded APK or custom recomp to your 1-tap launcher.</p>
          </div>
        </div>

        <form id="custom-game-form" onsubmit="window.DroidRecomp.handleSaveCustomGame(event)" style="margin-top: 18px;">
          <div class="custom-form-group">
            <label class="custom-form-label">Game Title *</label>
            <input type="text" id="cg-title" class="custom-form-input" required placeholder="e.g. Portal (Source Engine), AM2R, Sonic 3 A.I.R.">
          </div>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
            <div class="custom-form-group">
              <label class="custom-form-label">Original System *</label>
              <select id="cg-origin" class="custom-form-select" required>
                <option value="n64">Nintendo 64</option>
                <option value="x360">Xbox 360</option>
                <option value="xbox">Xbox</option>
                <option value="gc">GameCube</option>
                <option value="wii">Wii</option>
                <option value="ps1">PlayStation 1</option>
                <option value="ps2">PlayStation 2</option>
                <option value="psp">PSP</option>
                <option value="pc_classic" selected>Classic PC / Source Port</option>
                <option value="snes">SNES</option>
                <option value="gba">GBA</option>
              </select>
            </div>

            <div class="custom-form-group">
              <label class="custom-form-label">Port Architecture</label>
              <select id="cg-type" class="custom-form-select">
                <option value="Custom Sideload" selected>Custom Sideload</option>
                <option value="Static Recomp">Static Recompilation</option>
                <option value="Native Decomp">Native Decompilation</option>
                <option value="Source Port">Source Port</option>
              </select>
            </div>
          </div>

          <div class="custom-form-group">
            <label class="custom-form-label">Android Package Name *</label>
            <input type="text" id="cg-package" class="custom-form-input" required placeholder="e.g. org.srceng.source, com.am2r.android">
            <div class="custom-form-hint">Used to launch the app directly on your Android device with 1 tap.</div>
          </div>

          <div class="custom-form-group">
            <label class="custom-form-label">Cover Image URL (Optional)</label>
            <input type="url" id="cg-cover" class="custom-form-input" placeholder="https://... (Leave blank for default system cover art)">
          </div>

          <div class="custom-form-group">
            <label class="custom-form-label">APK Download URL or Notes (Optional)</label>
            <input type="text" id="cg-apk" class="custom-form-input" placeholder="https://github.com/... or download notes">
          </div>

          <div style="display: flex; gap: 10px; margin-top: 22px;">
            <button type="button" class="btn btn-secondary" onclick="window.DroidRecomp.closeCustomModal()" style="flex: 1;">Cancel</button>
            <button type="submit" class="btn btn-primary" style="flex: 2;">Save to Launcher</button>
          </div>
        </form>
      </div>
    `;

    customModal.removeAttribute('hidden');
    customModal.style.removeProperty('display');
    customModal.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeCustomGameModal() {
    const customModal = document.getElementById('custom-game-modal');
    if (!customModal) return;
    customModal.setAttribute('hidden', '');
    customModal.classList.remove('open');
    customModal.style.setProperty('display', 'none', 'important');
    document.body.style.overflow = '';
  }

  function saveCustomGame(gameObj) {
    customGames.unshift(gameObj);
    localStorage.setItem('droidrecomp_custom_games', JSON.stringify(customGames));

    if (!installedGames.includes(gameObj.id)) {
      installedGames.unshift(gameObj.id);
      localStorage.setItem('droidrecomp_installed', JSON.stringify(installedGames));
    }

    mergeCustomGames();
    closeCustomGameModal();
    showToast(`Added "${gameObj.name}" to your Library!`);
    renderLibraryView();
  }

  function deleteCustomGame(id, event) {
    if (event) event.stopPropagation();
    if (!confirm('Are you sure you want to remove this custom game from your launcher?')) return;

    customGames = customGames.filter(g => g.id !== id);
    localStorage.setItem('droidrecomp_custom_games', JSON.stringify(customGames));
    installedGames = installedGames.filter(gId => gId !== id);
    localStorage.setItem('droidrecomp_installed', JSON.stringify(installedGames));
    catalogData = catalogData.filter(g => g.id !== id);

    showToast('Removed custom game.');
    renderLibraryView();
  }

  // =========================================================================
  // VIEW: COMMUNITY RECOMP SUBMISSION PORTAL
  // =========================================================================
  function renderSubmitView() {
    viewContent.innerHTML = `
      <div class="submit-portal-container">
        <div style="margin-bottom: 24px;">
          <span class="tag tag-origin" style="margin-bottom: 10px; display: inline-block;">Community Catalog</span>
          <h1 style="font-family: var(--font-display); font-size: 2.2rem; font-weight: 900; color: var(--frost); margin-bottom: 8px;">Submit a New Recomp / Port</h1>
          <p style="color: var(--muted); font-size: 0.95rem; line-height: 1.5; max-width: 650px;">
            Ported or found an open-source static recompilation or game engine for Android? Submit it to the official master list so everyone can enjoy it.
          </p>
        </div>

        <div class="submit-portal-grid">
          <!-- Submission Form -->
          <form id="submission-wizard" onsubmit="window.DroidRecomp.handleOfficialSubmit(event)">
            <div style="background: var(--glass); border: 1px solid var(--line); border-radius: var(--radius-lg); padding: 24px; margin-bottom: 20px;">
              <h3 style="font-size: 1.1rem; font-weight: 800; color: var(--frost); margin-bottom: 16px;">1. Game & Port Information</h3>

              <div class="custom-form-group">
                <label class="custom-form-label">Game Title & Port Name *</label>
                <input type="text" id="sub-name" class="custom-form-input" required placeholder="e.g. Zelda 64 Recomp (Android)" oninput="window.DroidRecomp.updateSubmitPreview()">
              </div>

              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div class="custom-form-group">
                  <label class="custom-form-label">Original Console / System *</label>
                  <select id="sub-origin" class="custom-form-select" required onchange="window.DroidRecomp.updateSubmitPreview()">
                    <option value="n64">Nintendo 64</option>
                    <option value="x360">Xbox 360</option>
                    <option value="xbox">Xbox</option>
                    <option value="gc">GameCube</option>
                    <option value="wii">Wii</option>
                    <option value="ps1">PlayStation 1</option>
                    <option value="ps2">PlayStation 2</option>
                    <option value="psp">PSP</option>
                    <option value="pc_classic" selected>Classic PC / Source Port</option>
                    <option value="snes">SNES</option>
                    <option value="gba">GBA</option>
                  </select>
                </div>

                <div class="custom-form-group">
                  <label class="custom-form-label">Port Architecture *</label>
                  <select id="sub-type" class="custom-form-select" onchange="window.DroidRecomp.updateSubmitPreview()">
                    <option value="Static Recomp" selected>Static Recompilation</option>
                    <option value="Native Decomp">Native Decompilation</option>
                    <option value="Source Port">Source Port</option>
                    <option value="Compatibility Engine">Compatibility Engine</option>
                  </select>
                </div>
              </div>

              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <div class="custom-form-group">
                  <label class="custom-form-label">Author / Porter *</label>
                  <input type="text" id="sub-author" class="custom-form-input" required placeholder="e.g. Wiseguy, Community Porters" oninput="window.DroidRecomp.updateSubmitPreview()">
                </div>
                <div class="custom-form-group">
                  <label class="custom-form-label">Version</label>
                  <input type="text" id="sub-version" class="custom-form-input" placeholder="e.g. v1.0.0" value="v1.0.0" oninput="window.DroidRecomp.updateSubmitPreview()">
                </div>
              </div>
            </div>

            <div style="background: var(--glass); border: 1px solid var(--line); border-radius: var(--radius-lg); padding: 24px; margin-bottom: 20px;">
              <h3 style="font-size: 1.1rem; font-weight: 800; color: var(--frost); margin-bottom: 16px;">2. Release URLs & Binaries</h3>

              <div class="custom-form-group">
                <label class="custom-form-label">GitHub / Source Repository URL *</label>
                <input type="url" id="sub-repo" class="custom-form-input" required placeholder="https://github.com/owner/repository" oninput="window.DroidRecomp.updateSubmitPreview()">
              </div>

              <div class="custom-form-group">
                <label class="custom-form-label">Official Release APK URL</label>
                <input type="url" id="sub-apk" class="custom-form-input" placeholder="https://github.com/.../releases/download/.../app.apk" oninput="window.DroidRecomp.updateSubmitPreview()">
              </div>

              <div class="custom-form-group">
                <label class="custom-form-label">Box Art Cover Image URL</label>
                <input type="url" id="sub-cover" class="custom-form-input" placeholder="https://images.igdb.com/... (Vertical box art recommended)" oninput="window.DroidRecomp.updateSubmitPreview()">
              </div>



              <div style="display: flex; align-items: flex-start; gap: 10px; margin-top: 14px;">
                <input type="checkbox" id="sub-byor" required style="margin-top: 4px; accent-color: var(--brand);">
                <label for="sub-byor" style="font-size: 0.8rem; color: var(--muted); line-height: 1.4;">
                  <strong>100% Legal Clean-Room Declaration:</strong> I confirm this recompilation distributes executable code only, and zero copyrighted Nintendo/Sony/publisher game assets are included.
                </label>
              </div>
            </div>

            <!-- Actions Row -->
            <div class="submit-actions-row">
              <button type="submit" class="btn-github-issue">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
                <span>Submit to Master List (1-Click GitHub Issue)</span>
              </button>

              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                <button type="button" class="btn-copy-json" onclick="window.DroidRecomp.copySubmissionJson()">
                  <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
                  <span>Copy Catalog JSON</span>
                </button>
                <button type="button" class="btn-add-local" onclick="window.DroidRecomp.addSubmissionToLocal()">
                  <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                  <span>Test in My Library</span>
                </button>
              </div>
            </div>
          </form>

          <!-- Live Card Preview Sidebar -->
          <div class="submit-preview-box">
            <div class="submit-preview-title">
              <span>Live Card Preview</span>
              <span class="badge-android">Preview</span>
            </div>

            <div class="poster-card" id="preview-poster" style="cursor: default; max-width: 280px; margin: 0 auto;">
              <div class="poster-media">
                <img id="preview-img" src="favicon.svg" alt="Preview" style="background: #111b2e;">
                <span class="poster-badge" id="preview-badge">PC CLASSIC</span>
              </div>
              <div class="poster-info">
                <div class="poster-meta">
                  <span id="preview-type">Static Recomp</span>
                  <span id="preview-ver">v1.0.0</span>
                </div>
                <h3 class="poster-title" id="preview-title">Game Title</h3>
                <div class="poster-author" id="preview-author">by Community</div>
              </div>
            </div>

            <div style="margin-top: 18px; font-size: 0.8rem; color: var(--muted); line-height: 1.45; text-align: center;">
              This preview updates live as you type. Once submitted via GitHub, community reviewers verify controller mappings and ARM64 compatibility before merging.
            </div>
          </div>
        </div>
      </div>
    `;
  }


  // =========================================================================
  // UI COMPONENTS (POSTER & CARD)
  // =========================================================================
  function posterCard(game, rank) {
    return `
      <div class="poster-card" onclick="window.DroidRecomp.openModal('${game.id}')">
        <div class="poster-media">
          <img src="${game.cover}" alt="${escapeHtml(game.name)}" loading="lazy" referrerpolicy="no-referrer">
          ${rank ? `<span class="poster-rank">#${rank}</span>` : ''}
          <span class="poster-badge">${originLabel(game.origin)}</span>
        </div>
        <div class="poster-info">
          <h4 class="poster-title">${escapeHtml(game.name)}</h4>
          <p class="poster-sub">${game.type}</p>
        </div>
      </div>
    `;
  }

  function gameCard(game, rank) {
    const isSaved = savedGames.includes(game.id);
    const isInstalled = installedGames.includes(game.id);
    const pkg = getPackageName(game);
    return `
      <div class="game-card" onclick="window.DroidRecomp.openModal('${game.id}')">
        <div class="game-card-head">
          <img class="game-card-cover" src="${game.cover}" alt="${escapeHtml(game.name)}" loading="lazy" referrerpolicy="no-referrer">
          <div class="game-card-meta">
            <div class="game-card-tags">
              <span class="tag tag-origin" style="font-size: 0.65rem; padding: 2px 7px;">${originLabel(game.origin)}</span>
              ${game.graphics.turnip_recommended ? `<span class="tag tag-turnip" style="font-size: 0.65rem; padding: 2px 6px;">Turnip ⚡</span>` : ''}
              ${game.input.touch ? `<span class="tag tag-touch" style="font-size: 0.65rem; padding: 2px 6px;">Touch</span>` : ''}
            </div>
            <h3 class="game-card-title">${rank ? `<b style="color:var(--cyan); margin-right: 4px;">#${rank}</b> ` : ''}${escapeHtml(game.name)}</h3>
            <p class="game-card-by">by ${escapeHtml(game.author || 'Community')}</p>
            <p class="game-card-blurb">${escapeHtml(game.blurb || '')}</p>
          </div>
        </div>
        <div class="game-card-foot">
          <span>${game.version || 'v1.0'}</span>
          <div class="game-card-actions" onclick="event.stopPropagation()">
            <button type="button" class="btn-card-action" onclick="window.DroidRecomp.toggleSave('${game.id}')" title="Save to library">
              <svg viewBox="0 0 24 24" width="13" height="13" fill="${isSaved ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            </button>
            <button type="button" class="btn-card-action" onclick="window.DroidRecomp.openModal('${game.id}')">Details</button>
          </div>
        </div>
      </div>
    `;
  }

  // =========================================================================
  // GAME DETAIL MODAL
  // =========================================================================
  function openGameModal(id) {
    const game = catalogData.find(g => g.id === id);
    if (!game) return;

    const isSaved = savedGames.includes(game.id);
    const isInstalled = installedGames.includes(game.id);
    const pkg = getPackageName(game);

    modalContent.innerHTML = `
      <div class="modal-hero" style="background-image: url('${game.hero || game.cover}');">
        <div class="modal-hero-gradient"></div>
      </div>

      <div class="modal-header-content">
        <img class="modal-cover" src="${game.cover}" alt="${escapeHtml(game.name)}" referrerpolicy="no-referrer">
        <div class="modal-title-area">
          <div style="display: flex; gap: 8px; margin-bottom: 8px; flex-wrap: wrap;">
            <span class="tag tag-origin">${originLabel(game.origin)}</span>
            <span class="tag">${game.type}</span>
            <span class="tag" style="background: rgba(52, 211, 153, 0.2); color: var(--success); border-color: rgba(52, 211, 153, 0.4);">Verified Playable</span>
            ${game.graphics.turnip_recommended ? `<span class="tag tag-turnip">⚡ Adreno Turnip Rec.</span>` : ''}
          </div>
          <h1 class="modal-title">${escapeHtml(game.name)}</h1>
          ${game.game && game.game !== game.name ? `<p class="modal-based">Rebuilt from <strong>${escapeHtml(game.game)}</strong></p>` : ''}
          <p style="font-size: 0.85rem; color: var(--muted);">Maintained by <strong>${escapeHtml(game.author || 'Community')}</strong></p>
        </div>
      </div>

      <!-- TABS -->
      <nav class="modal-tabs" role="tablist">
        <button type="button" class="modal-tab active" data-tab="overview">Overview</button>
        <button type="button" class="modal-tab" data-tab="setup">Setup & Assets</button>
        <button type="button" class="modal-tab" data-tab="releases">Downloads & Updates</button>
      </nav>

      <div class="modal-inner">
        <!-- LEFT TAB PANELS -->
        <div class="modal-main-body">
          <!-- PANEL 1: OVERVIEW -->
          <div class="modal-panel" id="panel-overview">
            <h3 style="font-family: var(--font-display); font-size: 1.15rem; margin-bottom: 8px;">About this Recompilation</h3>
            <p style="color: var(--muted); margin-bottom: 16px;">${escapeHtml(game.blurb || '')}</p>

            <h4 style="font-family: var(--font-display); font-size: 0.95rem; margin-bottom: 10px; color: var(--cyan);">Key Features & Enhancements</h4>
            <ul class="modal-features-list">
              ${(game.features || []).map(f => `
                <li>
                  <svg viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" fill="none" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                  <span>${escapeHtml(f)}</span>
                </li>
              `).join('')}
            </ul>

            <div class="disc-note" style="margin-top: 24px;">
              <span class="kicker">No Game Files Included</span>
              <p>DroidRecomp and its developer releases do not distribute game assets. You must own and supply your own legal dump of <em>${escapeHtml(game.game || game.name)}</em>.</p>
            </div>
          </div>

          <!-- PANEL 2: SETUP & ASSETS -->
          <div class="modal-panel" id="panel-setup" hidden>
            <h3 style="font-family: var(--font-display); font-size: 1.15rem; margin-bottom: 8px;">Asset Setup Guide</h3>
            <p style="color: var(--muted); margin-bottom: 14px;">Follow these steps to extract and place your assets for this port:</p>

            <div style="background: rgba(244, 248, 252, 0.04); border: 1px solid var(--line); border-radius: var(--radius-md); padding: 16px; margin-bottom: 16px;">
              <strong style="color: var(--cyan); display: block; margin-bottom: 4px;">Required Game Files:</strong>
              <div style="font-family: monospace; font-size: 0.85rem; color: #fff;">${escapeHtml(game.needs || 'Original ROM dump')}</div>
            </div>

            <div style="background: rgba(244, 248, 252, 0.04); border: 1px solid var(--line); border-radius: var(--radius-md); padding: 16px; margin-bottom: 16px;">
              <strong style="color: var(--cyan); display: block; margin-bottom: 4px;">Target Storage Directory:</strong>
              <div style="font-family: monospace; font-size: 0.82rem; color: #fff; word-break: break-all;">/sdcard/Android/data/com.recomp.${game.id.replace(/-/g, '.')}/files/</div>
            </div>

            <!-- LOCAL ROM HASH CHECKER IN MODAL -->
            <div class="rom-checker-box">
              <input type="file" id="modal-rom-input" style="display: none;" onchange="window.DroidRecomp.verifyRomFile(this.files[0], '${game.id}')">
              <div class="rom-drop-zone" onclick="document.getElementById('modal-rom-input').click()">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--cyan); margin-bottom: 4px;"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                <div style="font-weight: 600; font-size: 0.9rem;">Test Your ROM File Hash Locally</div>
                <div style="font-size: 0.75rem; color: var(--muted);">Click to verify SHA-1 checksum</div>
              </div>
              <div id="modal-rom-output" style="margin-top: 10px; font-size: 0.8rem; font-family: monospace; display: none;"></div>
            </div>
          </div>

          <!-- PANEL 3: RELEASES & UPDATES -->
          <div class="modal-panel" id="panel-releases" hidden>
            <h3 style="font-family: var(--font-display); font-size: 1.15rem; margin-bottom: 8px;">Releases & Source Code</h3>
            <p style="color: var(--muted); margin-bottom: 14px;">Binary builds are distributed directly from the developer's official releases.</p>

            <div style="background: rgba(244, 248, 252, 0.04); border: 1px solid var(--line); border-radius: var(--radius-md); padding: 18px; margin-bottom: 14px;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <strong style="font-size: 1.05rem;">Current Release: ${game.version || 'Latest'}</strong>
                <span class="tag tag-origin" style="font-size: 0.7rem;">ARM64</span>
              </div>
              <p style="font-size: 0.85rem; color: var(--muted); margin-bottom: 14px;">Target architecture: <code>arm64-v8a</code>. Verified clean build with native graphics pipeline.</p>
              
              <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                ${game.apk_url ? `
                  <a class="btn btn-primary" href="${game.apk_url}" target="_blank" rel="noopener">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    <span>Direct APK Download</span>
                  </a>
                ` : ''}
                ${game.repo_url ? `
                  <a class="btn btn-secondary" href="${game.repo_url}" target="_blank" rel="noopener">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>
                    <span>GitHub Repository</span>
                  </a>
                ` : ''}
              </div>
            </div>
          </div>
        </div>

        <!-- RIGHT FACTS SIDEBAR -->
        <aside class="modal-sidebar">
          <div class="modal-sidebar-card">
            <div class="modal-installed-section">
              ${isInstalled ? `
                <div style="display: flex; flex-direction: column; gap: 8px; width: 100%;">
                  <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span class="badge-installed">✓ Installed on Device</span>
                    <button type="button" class="btn btn-secondary" style="padding: 3px 8px; font-size: 0.72rem;" onclick="window.DroidRecomp.toggleInstalled('${game.id}', event)">Unmark</button>
                  </div>
                  <button type="button" class="btn-launch-game" onclick="window.DroidRecomp.launchGame('${game.id}', event)">
                    <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"/></svg>
                    <span>LAUNCH GAME</span>
                  </button>
                </div>
              ` : `
                <button type="button" class="btn btn-secondary btn-full" onclick="window.DroidRecomp.toggleInstalled('${game.id}', event)">
                  <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="6" width="20" height="12" rx="3"/><circle cx="8" cy="12" r="1.5"/><circle cx="16" cy="12" r="1.5"/><path d="M12 9v6M9 12h6"/></svg>
                  <span>+ Mark as Installed</span>
                </button>
              `}
            </div>
            ${game.apk_url ? `
              <a class="btn btn-primary btn-full" href="${game.apk_url}" target="_blank" rel="noopener">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                <span>Download APK (ARM64)</span>
              </a>
            ` : ''}

            ${game.obtainium_url ? `
              <a class="btn btn-secondary btn-full" href="${game.obtainium_url}" title="Add to Obtainium">
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
                <span>1-Click Obtainium Sync</span>
              </a>
            ` : ''}

            <button type="button" class="btn btn-secondary btn-full" onclick="window.DroidRecomp.toggleSave('${game.id}', true)">
              <svg viewBox="0 0 24 24" width="16" height="16" fill="${isSaved ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
              <span id="modal-save-label">${isSaved ? 'In Your Library' : 'Bookmark to Library'}</span>
            </button>

            <dl style="margin-top: 10px;">
              <div class="fact-row"><dt>System</dt><dd>${originLabel(game.origin)}</dd></div>
              <div class="fact-row"><dt>Port Type</dt><dd>${game.type}</dd></div>
              <div class="fact-row"><dt>Min Android</dt><dd>${game.min_android || 'Android 8.0+'}</dd></div>
              <div class="fact-row"><dt>Input</dt><dd>${game.input.touch ? 'Touch + Gamepad' : 'Physical Gamepad'}</dd></div>
              <div class="fact-row"><dt>Renderer</dt><dd>${game.graphics.backend || 'Vulkan 1.3'}</dd></div>
              <div class="fact-row"><dt>Target FPS</dt><dd>${game.graphics.fps_target || 60} FPS</dd></div>
              <div class="fact-row"><dt>Mesa Turnip</dt><dd>${game.graphics.turnip_recommended ? 'Recommended ⚡' : 'Standard'}</dd></div>
              <div class="fact-row"><dt>Version</dt><dd>${game.version || 'v1.0'}</dd></div>
            </dl>
          </div>
        </aside>
      </div>
    `;

    // Modal Tabs logic
    const tabs = modalContent.querySelectorAll('.modal-tab');
    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        const target = tab.getAttribute('data-tab');
        modalContent.querySelectorAll('.modal-panel').forEach(p => p.hidden = true);
        const activePanel = modalContent.querySelector(`#panel-${target}`);
        if (activePanel) activePanel.hidden = false;
      });
    });

    gameModal.removeAttribute('hidden');
    gameModal.classList.add('open');
    gameModal.style.setProperty('display', 'flex', 'important');
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    gameModal.setAttribute('hidden', '');
    gameModal.classList.remove('open');
    gameModal.style.setProperty('display', 'none', 'important');
    document.body.style.overflow = '';
  }

  // =========================================================================
  // SEARCH MODAL LOGIC
  // =========================================================================
  function openSearch() {
    searchModal.removeAttribute('hidden');
    searchModal.classList.add('open');
    searchModal.style.setProperty('display', 'flex', 'important');
    searchInput.value = '';
    searchInput.focus();
    renderSearchResults('');
    document.body.style.overflow = 'hidden';
  }

  function closeSearch() {
    searchModal.setAttribute('hidden', '');
    searchModal.classList.remove('open');
    searchModal.style.setProperty('display', 'none', 'important');
    document.body.style.overflow = '';
  }

  function renderSearchResults(query) {
    const q = query.trim().toLowerCase();
    if (!q) {
      searchResults.innerHTML = `<div style="text-align: center; padding: 30px; color: var(--muted); font-size: 0.9rem;">Type to search 370+ verified Android recompilations & ports...</div>`;
      return;
    }

    const matches = catalogData.filter(g => {
      return (
        g.name.toLowerCase().includes(q) ||
        (g.game && g.game.toLowerCase().includes(q)) ||
        (g.origin && g.origin.toLowerCase().includes(q)) ||
        (g.author && g.author.toLowerCase().includes(q)) ||
        (g.type && g.type.toLowerCase().includes(q)) ||
        (g.blurb && g.blurb.toLowerCase().includes(q))
      );
    }).slice(0, 15);

    if (!matches.length) {
      searchResults.innerHTML = `<div style="text-align: center; padding: 40px; color: var(--muted);">No recomps found matching "<strong>${escapeHtml(query)}</strong>"</div>`;
      return;
    }

    searchResults.innerHTML = matches.map(game => `
      <div class="search-item" onclick="window.DroidRecomp.selectSearchResult('${game.id}')">
        <img class="search-item-thumb" src="${game.cover}" alt="" referrerpolicy="no-referrer">
        <div class="search-item-info">
          <div class="search-item-title">${escapeHtml(game.name)}</div>
          <div class="search-item-meta">${originLabel(game.origin)} &bull; ${game.type} &bull; ${game.version || 'v1.0'}</div>
        </div>
        <span class="tag tag-origin" style="font-size: 0.65rem;">View</span>
      </div>
    `).join('');
  }

  // =========================================================================
  // BOOKMARK / SAVED SYSTEM
  // =========================================================================
  function toggleSave(id, fromModal = false) {
    const idx = savedGames.indexOf(id);
    if (idx >= 0) {
      savedGames.splice(idx, 1);
    } else {
      savedGames.push(id);
    }
    localStorage.setItem('droidrecomp_saved', JSON.stringify(savedGames));
    updateSavedCount();

    if (fromModal) {
      const label = document.getElementById('modal-save-label');
      if (label) label.textContent = savedGames.includes(id) ? 'In Your Library' : 'Bookmark to Library';
    } else if (currentRoute === 'saved') {
      renderSavedView();
    }
  }

  function updateSavedCount() {
    if (savedCountBadge) savedCountBadge.textContent = savedGames.length;
  }

  // =========================================================================
  // OBTAINIUM JSON EXPORT
  // =========================================================================
  function exportObtainiumPack() {
    const appsToExport = catalogData.filter(g => g.repo);
    const pack = {
      apps: appsToExport.map(g => ({
        id: `com.recomp.${g.id.replace(/-/g, '.')}`,
        url: `https://github.com/${g.repo}`,
        author: g.author || 'Community',
        name: g.name,
        preferredApkIndex: 0,
        additionalSettings: {
          includePrereleases: false,
          fallbackToOlderReleases: true,
          filterReleaseTitlesByRegEx: "",
          filterReleaseNotesByRegEx: "",
          filterAppTitlesByRegEx: ".*(arm64|android).*"
        }
      })),
      settings: {
        theme: "dark"
      }
    };

    const blob = new Blob([JSON.stringify(pack, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'DroidRecomp_Obtainium_Pack.json';
    a.click();
    URL.revokeObjectURL(url);
  }

  // =========================================================================
  // ROM SHA-1 HASH CALCULATOR (Local Web Crypto API)
  // =========================================================================
  async function verifyRomFile(file, gameId) {
    if (!file) return;
    const out = document.getElementById(gameId ? 'modal-rom-output' : 'rom-hash-output');
    if (!out) return;

    out.style.display = 'block';
    out.style.color = 'var(--muted)';
    out.textContent = `Reading ${file.name} (${(file.size / (1024 * 1024)).toFixed(1)} MB)...`;

    try {
      const buffer = await file.arrayBuffer();
      const hashBuffer = await crypto.subtle.digest('SHA-1', buffer);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');

      out.innerHTML = `
        <div style="color: #fff; margin-bottom: 4px;">File: <strong>${escapeHtml(file.name)}</strong></div>
        <div style="color: var(--cyan); word-break: break-all;">SHA-1: <strong>${hashHex}</strong></div>
        <div style="color: var(--success); margin-top: 6px;">✓ Calculated locally without upload. Check if it matches requirements.</div>
      `;
    } catch (err) {
      out.style.color = 'var(--danger)';
      out.textContent = `Error reading file: ${err.message}`;
    }
  }

  // =========================================================================
  // UTILITIES & HELPERS
  // =========================================================================
  function setAmbientBackdrop(imageUrl) {
    if (backdropImg && imageUrl) {
      backdropImg.style.backgroundImage = `url('${imageUrl}')`;
    }
  }

  function originLabel(origin) {
    const map = {
      'n64': 'Nintendo 64',
      'x360': 'Xbox 360',
      'xbox': 'Xbox',
      'gc': 'GameCube',
      'wii': 'Wii',
      'ps1': 'PS1',
      'ps2': 'PS2',
      'psp': 'PSP',
      'pc_classic': 'PC Engine',
      'snes': 'SNES',
      'gba': 'GBA'
    };
    return map[origin] || origin.toUpperCase();
  }

  function escapeHtml(str) {
    return String(str || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  // Event Listeners
  function setupEventListeners() {
    // Navigation Routing
    window.addEventListener('hashchange', handleRoute);

    // Global Search Modal Events
    const searchOpenBtn = document.getElementById('search-open');
    const mobileSearchBtn = document.getElementById('mobile-search-btn');
    const searchCloseBtn = document.getElementById('search-close');
    const modalCloseBtn = document.getElementById('modal-close');

    if (searchOpenBtn) searchOpenBtn.addEventListener('click', openSearch);
    if (mobileSearchBtn) mobileSearchBtn.addEventListener('click', openSearch);
    if (searchCloseBtn) searchCloseBtn.addEventListener('click', closeSearch);
    if (modalCloseBtn) modalCloseBtn.addEventListener('click', closeModal);

    // Close on backdrop click
    if (searchModal) {
      searchModal.addEventListener('click', (e) => {
        if (e.target === searchModal) closeSearch();
      });
    }

    if (gameModal) {
      gameModal.addEventListener('click', (e) => {
        if (e.target === gameModal) closeModal();
      });
    }

    // Keyboard Shortcuts
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        closeSearch();
        closeModal();
      }
      if ((e.key === '/' || (e.ctrlKey && e.key === 'k')) && !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) {
        e.preventDefault();
        openSearch();
      }
    });

    // Search Input debounce
    if (searchInput) {
      searchInput.addEventListener('input', (e) => {
        renderSearchResults(e.target.value);
      });
    }

    // Search Quick Tags
    document.querySelectorAll('.tag-chip').forEach(btn => {
      btn.addEventListener('click', () => {
        const q = btn.getAttribute('data-query');
        if (searchInput) {
          searchInput.value = q;
          renderSearchResults(q);
        }
      });
    });

    // Origin Pills in Header
    document.querySelectorAll('#origin-pills [data-origin]').forEach(pill => {
      pill.addEventListener('click', () => {
        const origin = pill.getAttribute('data-origin');
        window.DroidRecomp.setOrigin(origin);
      });
    });

    // Theme Toggle
    if (themeToggle) {
      themeToggle.addEventListener('click', toggleTheme);
    }

    // UI Mode Toggle
    if (uiModeToggle) {
      uiModeToggle.addEventListener('click', toggleUiMode);
    }

    // Obtainium Pack button
    const btnObtainium = document.getElementById('btn-obtainium-pack');
    if (btnObtainium) {
      btnObtainium.addEventListener('click', exportObtainiumPack);
    }

    const footObtainium = document.getElementById('foot-obtainium-link');
    if (footObtainium) {
      footObtainium.addEventListener('click', (e) => {
        e.preventDefault();
        exportObtainiumPack();
      });
    }
  }

  // Public API attached to window for inline onclick handlers
  window.DroidRecomp = {
    openModal: openGameModal,
    openAddCustomGameModal: openAddCustomGameModal,
    closeCustomModal: closeCustomGameModal,
    handleSaveCustomGame: function(e) {
      e.preventDefault();
      const title = document.getElementById('cg-title').value.trim();
      const origin = document.getElementById('cg-origin').value;
      const type = document.getElementById('cg-type').value;
      const pkg = document.getElementById('cg-package').value.trim();
      const cover = document.getElementById('cg-cover').value.trim() || 'favicon.svg';
      const apk = document.getElementById('cg-apk').value.trim();

      const slug = 'custom_' + title.toLowerCase().replace(/[^a-z0-9]/g, '_') + '_' + Date.now();
      const gameObj = {
        id: slug,
        name: title,
        game: title,
        origin: origin,
        type: type,
        version: "v1.0",
        author: "User Sideload",
        repo: "",
        repo_url: "",
        apk_url: apk || (pkg ? 'intent:#Intent;package=' + pkg + ';category=android.intent.category.LAUNCHER;action=android.intent.action.MAIN;end' : ''),
        obtainium_url: "",
        cover: cover,
        hero: cover,
        min_android: "Android 8.0+",
        architectures: ["arm64-v8a"],
        input: { touch: true, controller: true, gyro: false, controller_recommended: true },
        graphics: { backend: "Vulkan / OpenGL", turnip_recommended: false, fps_target: 60 },
        needs: "Custom sideloaded game files",
        blurb: "User-added unlisted game in personal library.",
        features: ["Personal Library Game", "1-Tap Launcher Ready"],
        downloads: 1,
        stars: 5,
        package_name: pkg,
        isCustom: true
      };

      saveCustomGame(gameObj);
    },
    deleteCustomGame: deleteCustomGame,
    updateSubmitPreview: function() {
      const name = document.getElementById('sub-name')?.value.trim() || 'Game Title';
      const origin = document.getElementById('sub-origin')?.value || 'pc_classic';
      const type = document.getElementById('sub-type')?.value || 'Static Recomp';
      const author = document.getElementById('sub-author')?.value.trim() || 'Community';
      const ver = document.getElementById('sub-version')?.value.trim() || 'v1.0.0';
      const cover = document.getElementById('sub-cover')?.value.trim() || 'favicon.svg';

      const titleEl = document.getElementById('preview-title');
      const badgeEl = document.getElementById('preview-badge');
      const typeEl = document.getElementById('preview-type');
      const verEl = document.getElementById('preview-ver');
      const authorEl = document.getElementById('preview-author');
      const imgEl = document.getElementById('preview-img');

      if (titleEl) titleEl.textContent = name;
      if (badgeEl) badgeEl.textContent = originLabel(origin);
      if (typeEl) typeEl.textContent = type;
      if (verEl) verEl.textContent = ver;
      if (authorEl) authorEl.textContent = 'by ' + author;
      if (imgEl && cover) imgEl.src = cover;
    },
    buildSubmissionJson: function() {
      const name = document.getElementById('sub-name')?.value.trim() || 'Untitled Recomp';
      const origin = document.getElementById('sub-origin')?.value || 'pc_classic';
      const type = document.getElementById('sub-type')?.value || 'Static Recomp';
      const author = document.getElementById('sub-author')?.value.trim() || 'Community Porters';
      const ver = document.getElementById('sub-version')?.value.trim() || 'v1.0.0';
      const repo = document.getElementById('sub-repo')?.value.trim() || '';
      const apk = document.getElementById('sub-apk')?.value.trim() || '';
      const cover = document.getElementById('sub-cover')?.value.trim() || 'favicon.svg';
      const needs = document.getElementById('sub-needs')?.value.trim() || 'Original game files required';

      const slug = name.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-');
      return {
        id: slug,
        name: name,
        game: name,
        origin: origin,
        type: type,
        version: ver,
        author: author,
        repo: repo.replace('https://github.com/', ''),
        repo_url: repo,
        apk_url: apk,
        obtainium_url: repo ? 'obtainium://add/' + repo : '',
        cover: cover,
        hero: cover,
        min_android: "Android 8.0+",
        architectures: ["arm64-v8a"],
        input: { touch: true, controller: true, gyro: false, controller_recommended: true },
        graphics: { backend: "Vulkan 1.3", turnip_recommended: false, fps_target: 60 },
        needs: needs,
        blurb: name + ' native port for Android.',
        features: ["Native ARM64 Port", "Controller Support"],
        downloads: 1000,
        stars: 100
      };
    },
    copySubmissionJson: function() {
      const data = window.DroidRecomp.buildSubmissionJson();
      const str = JSON.stringify(data, null, 2);
      navigator.clipboard.writeText(str).then(() => {
        showToast('Copied submission JSON to clipboard!');
      }).catch(() => {
        alert('Catalog JSON:\n' + str);
      });
    },
    handleOfficialSubmit: function(e) {
      e.preventDefault();
      const data = window.DroidRecomp.buildSubmissionJson();
      const issueTitle = encodeURIComponent('[Recomp Submission] ' + data.name + ' (' + data.origin.toUpperCase() + ')');
      const issueBody = encodeURIComponent(
        '### New Android Recomp Submission\n\n' +
        '**Game Name:** ' + data.name + '\n' +
        '**Original Console:** ' + data.origin + '\n' +
        '**Port Architecture:** ' + data.type + '\n' +
        '**Repository:** ' + data.repo_url + '\n' +
        '**APK Download:** ' + data.apk_url + '\n' +
        '**ROM / Asset Requirements:** ' + data.needs + '\n\n' +
        '```json\n' + JSON.stringify(data, null, 2) + '\n```\n\n' +
        '- [x] I confirm this recomp distributes clean-room binaries without copyrighted ROM assets.'
      );
      const url = 'https://github.com/MooPuu/droid-recomp/issues/new?title=' + issueTitle + '&body=' + issueBody;
      window.open(url, '_blank');
      showToast('Opened GitHub Issue generator! Complete submission on GitHub.');
    },
    addSubmissionToLocal: function() {
      const data = window.DroidRecomp.buildSubmissionJson();
      saveCustomGame(data);
      window.location.hash = 'library';
    },
    setEmulatorFilter: function(system) {
      emulatorFilter = system;
      renderEmulatorsView();
    },
    searchEmulators: function(query) {
      emulatorSearchQuery = query;
      renderEmulatorsView();
      const input = document.getElementById('emu-search-input');
      if (input) {
        input.focus();
        input.selectionStart = input.selectionEnd = input.value.length;
      }
    },
    closeModal: closeModal,
    toggleTheme: toggleTheme,
    toggleUiMode: toggleUiMode,
    setOrigin: function (origin) {
      activeOrigin = origin;
      document.querySelectorAll('#origin-pills [data-origin]').forEach(el => {
        el.classList.toggle('on', el.getAttribute('data-origin') === activeOrigin);
      });
      if (currentRoute !== 'all') {
        currentRoute = 'all';
        window.location.hash = origin === 'all' ? 'all' : origin;
      } else {
        renderAllView();
      }
    },
    setType: function (type) {
      filterType = type;
      renderAllView();
    },
    setInput: function (input) {
      filterInput = input;
      renderAllView();
    },
    toggleTurnip: function () {
      filterTurnip = !filterTurnip;
      renderAllView();
    },
    resetFilters: function () {
      activeOrigin = 'all';
      filterType = 'all';
      filterInput = 'all';
      filterTurnip = false;
      renderAllView();
    },
    toggleSave: toggleSave,
    launchGame: launchGame,
    toggleInstalled: toggleInstalled,
    setLibraryTab: setLibraryTab,
    selectSearchResult: function (id) {
      closeSearch();
      openGameModal(id);
    },
    exportSavedToObtainium: exportObtainiumPack,
    verifyRomFile: verifyRomFile,
    handleSubmitPort: function (e) {
      e.preventDefault();
      alert('Thank you! Your submission has been received and queued for community controller & ARM64 verification.');
      window.location.hash = 'discover';
    }
  };

  // Embedded Backup Catalog
  function getEmbeddedCatalog() {
    return [
      {
        id: "zelda-64-recomp-android",
        name: "Zelda 64: Recompiled (Android)",
        game: "The Legend of Zelda: Majora's Mask",
        origin: "n64",
        type: "Static Recomp",
        version: "v1.2.2",
        author: "Zelda64Recomp / AurelioB",
        repo: "Zelda64Recomp/Zelda64Recomp",
        repo_url: "https://github.com/Zelda64Recomp/Zelda64Recomp",
        apk_url: "https://github.com/Zelda64Recomp/Zelda64Recomp/releases/latest",
        obtainium_url: "obtainium://app/%7B%22id%22%3A%22com.recomp.zelda64%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2FZelda64Recomp/Zelda64Recomp%22%7D",
        cover: "https://images.igdb.com/igdb/image/upload/t_cover_big/co64z4.jpg",
        hero: "https://images.igdb.com/igdb/image/upload/t_1080p/sc87a8.jpg",
        min_android: "Android 8.0+",
        architectures: ["arm64-v8a"],
        input: { touch: true, controller: true, gyro: true, controller_recommended: false },
        graphics: { backend: "Vulkan 1.3", turnip_recommended: false, fps_target: 120 },
        needs: "The Legend of Zelda: Majora's Mask (USA) v1.0 ROM (Z64 format, SHA1: d6133ace...)",
        blurb: "Majora's Mask as a native ARM64 Android app: high frame rates up to 120 FPS, widescreen, touch controls, and gyroscope aiming.",
        features: ["Native ARM64 Execution", "Up to 120 FPS Interpolation", "Configurable Touch Controls", "Gyroscope Aiming Support", "High Efficiency Vulkan Pipeline"],
        downloads: 380000,
        stars: 7553
      },
      {
        id: "banjo-kazooie-recomp",
        name: "Banjo-Kazooie Recomp",
        game: "Banjo-Kazooie",
        origin: "n64",
        type: "Static Recomp",
        version: "v1.0.0",
        author: "AurelioB (N64Recomp)",
        repo: "AurelioB/BanjoRecomp-Android",
        repo_url: "https://github.com/AurelioB/BanjoRecomp-Android",
        apk_url: "https://github.com/AurelioB/BanjoRecomp-Android/releases/latest",
        obtainium_url: "obtainium://app/%7B%22id%22%3A%22com.recomp.banjo%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2FAurelioB/BanjoRecomp-Android%22%7D",
        cover: "https://images.igdb.com/igdb/image/upload/t_cover_big/co2048.jpg",
        hero: "https://images.igdb.com/igdb/image/upload/t_1080p/sc66b3.jpg",
        min_android: "Android 8.0+",
        architectures: ["arm64-v8a"],
        input: { touch: true, controller: true, gyro: false, controller_recommended: false },
        graphics: { backend: "Vulkan 1.3", turnip_recommended: false, fps_target: 120 },
        needs: "Banjo-Kazooie (USA) v1.0 ROM (.z64)",
        blurb: "Rare's 3D collect-a-thon rebuilt natively for Android with RT64 rendering, instant load times, and true widescreen support.",
        features: ["60/120 FPS Rendering", "16:9 Widescreen Fixes", "Dual Analog Camera Support", "Touch & Physical Gamepad Support"],
        downloads: 145000,
        stars: 3200
      },
      {
        id: "forza-horizon",
        name: "Forza Horizon (Pinyon Shift)",
        game: "Forza Horizon (2012)",
        origin: "x360",
        type: "Static Recomp",
        version: "v0.6.0",
        author: "arcanite24 (Pinyon Shift)",
        repo: "",
        repo_url: "",
        apk_url: "https://droidports.com/games/forza-horizon/",
        obtainium_url: "",
        cover: "https://images.igdb.com/igdb/image/upload/t_cover_big/co1x4n.jpg",
        hero: "https://images.igdb.com/igdb/image/upload/t_1080p/sc7xsn.jpg",
        min_android: "Android 10.0+ (ARM64)",
        architectures: ["arm64-v8a"],
        input: { touch: false, controller: true, gyro: false, controller_recommended: true },
        graphics: { backend: "Vulkan 1.3", turnip_recommended: true, fps_target: 60 },
        needs: "Xbox 360 Forza Horizon (2012) Disc dump / ISO",
        blurb: "Playground Games' open-world festival racer statically recompiled from Xbox 360 PowerPC instructions into native ARM64 code.",
        features: ["AMD FSR 2/3 Temporal Upscaling", "60 FPS Colorado Open World", "Adreno Turnip Vulkan Tested", "Controller Auto-Mapping"],
        downloads: 85000,
        stars: 2900
      }
    ];
  }

  // Start on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
