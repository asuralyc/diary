// 日記 App 主要 JavaScript 檔案

// 全域變數
let diaryEntries = [];
let currentDate = new Date();
let settings = {
    theme: 'default',
    fontSize: 'medium',
    darkMode: false,
    reminderEnabled: true,
    reminderTime: '21:00',
    privacyEnabled: false,
    moodAnalysis: true
};

// 初始化應用程式
document.addEventListener('DOMContentLoaded', function() {
    loadSettings();
    loadDiaryEntries();
    applyTheme();
});

// 本地儲存管理
function saveDiaryEntries() {
    localStorage.setItem('diaryEntries', JSON.stringify(diaryEntries));
}

function loadDiaryEntries() {
    const stored = localStorage.getItem('diaryEntries');
    if (stored) {
        diaryEntries = JSON.parse(stored);
    } else {
        // 載入示例資料
        diaryEntries = getSampleData();
        saveDiaryEntries();
    }
}

function saveSettings() {
    localStorage.setItem('diarySettings', JSON.stringify(settings));
}

function loadSettings() {
    const stored = localStorage.getItem('diarySettings');
    if (stored) {
        settings = { ...settings, ...JSON.parse(stored) };
    }
}

// 取得示例資料
function getSampleData() {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);
    const dayBefore = new Date(today);
    dayBefore.setDate(today.getDate() - 2);

    return [
        {
            id: generateId(),
            date: formatDate(today),
            title: '',
            content: '今天去了海邊，看到了美麗的夕陽。心情特別放鬆，感覺所有的煩惱都被海浪帶走了。海風輕拂著臉龐，溫暖但不燥熱。我坐在沙灘上，看著太陽慢慢沉入海平線，天空被染成了橘紅色。這種時刻讓我想起了小時候和家人一起度假的美好時光。',
            mood: 'happy',
            emoji: '😊',
            weather: 'sunny',
            tags: ['海邊', '夕陽', '放鬆'],
            createdAt: today.toISOString(),
            modifiedAt: today.toISOString()
        },
        {
            id: generateId(),
            date: formatDate(yesterday),
            title: '工作挑戰',
            content: '工作上遇到了一些挑戰，但是透過團隊合作順利解決了。學到了很多新的東西，特別是關於溝通的重要性。雖然過程有些辛苦，但最終的成果讓我覺得很有成就感。',
            mood: 'neutral',
            emoji: '😐',
            weather: 'cloudy',
            tags: ['工作', '學習', '團隊'],
            createdAt: yesterday.toISOString(),
            modifiedAt: yesterday.toISOString()
        },
        {
            id: generateId(),
            date: formatDate(dayBefore),
            title: '電影之夜',
            content: '和朋友一起看電影，度過了愉快的晚上。友誼真的是人生中最珍貴的財富。我們看了一部很有趣的喜劇片，笑得肚子都痛了。之後還一起吃了宵夜，聊了很多以前的回憶。',
            mood: 'very-happy',
            emoji: '😆',
            weather: 'cloudy',
            tags: ['朋友', '電影', '友誼'],
            createdAt: dayBefore.toISOString(),
            modifiedAt: dayBefore.toISOString()
        }
    ];
}

// 工具函數
function generateId() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

function formatDate(date) {
    return date.toISOString().split('T')[0];
}

function formatDisplayDate(dateString) {
    const date = new Date(dateString);
    const options = {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long'
    };
    return date.toLocaleDateString('zh-TW', options);
}

function getMoodText(mood) {
    const moodMap = {
        'very-sad': '很難過',
        'sad': '難過',
        'neutral': '普通',
        'happy': '開心',
        'very-happy': '很開心',
        'love': '超開心'
    };
    return moodMap[mood] || '未知';
}

function getWeatherEmoji(weather) {
    const weatherMap = {
        'sunny': '☀️',
        'cloudy': '☁️',
        'rainy': '🌧️',
        'snowy': '❄️',
        'stormy': '⛈️'
    };
    return weatherMap[weather] || '';
}

// 首頁功能
function loadRecentEntries() {
    const container = document.getElementById('recentEntries');
    if (!container) return;

    const recentEntries = diaryEntries
        .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
        .slice(0, 3);

    if (recentEntries.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">📝</div>
                <h3>還沒有日記</h3>
                <p>開始寫下你的第一篇日記吧！</p>
                <a href="write.html" class="btn-primary">寫日記</a>
            </div>
        `;
        return;
    }

    container.innerHTML = recentEntries.map(entry => `
        <div class="diary-card" onclick="viewEntry('${entry.id}')">
            <div class="diary-header">
                <div class="diary-date">${formatDisplayDate(entry.date)}</div>
                <div class="diary-mood">
                    <span class="diary-mood-emoji">${entry.emoji}</span>
                </div>
            </div>
            ${entry.title ? `<div class="diary-title">${entry.title}</div>` : ''}
            <div class="diary-preview">${entry.content.substring(0, 100)}${entry.content.length > 100 ? '...' : ''}</div>
            ${entry.tags && entry.tags.length > 0 ? `
                <div class="diary-tags">
                    ${entry.tags.map(tag => `<span class="tag">${tag}</span>`).join('')}
                </div>
            ` : ''}
        </div>
    `).join('');
}

function updateStats() {
    const totalEntries = document.getElementById('totalEntries');
    const thisMonthEntries = document.getElementById('thisMonthEntries');
    const streakDays = document.getElementById('streakDays');

    if (totalEntries) totalEntries.textContent = diaryEntries.length;

    if (thisMonthEntries) {
        const currentMonth = new Date().getMonth();
        const currentYear = new Date().getFullYear();
        const monthEntries = diaryEntries.filter(entry => {
            const entryDate = new Date(entry.date);
            return entryDate.getMonth() === currentMonth && entryDate.getFullYear() === currentYear;
        });
        thisMonthEntries.textContent = monthEntries.length;
    }

    if (streakDays) {
        streakDays.textContent = calculateStreak();
    }
}

function calculateStreak() {
    if (diaryEntries.length === 0) return 0;

    const sortedEntries = diaryEntries
        .map(entry => entry.date)
        .sort((a, b) => new Date(b) - new Date(a));

    let streak = 0;
    let currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);

    for (let date of sortedEntries) {
        const entryDate = new Date(date);
        entryDate.setHours(0, 0, 0, 0);

        if (entryDate.getTime() === currentDate.getTime()) {
            streak++;
            currentDate.setDate(currentDate.getDate() - 1);
        } else if (entryDate.getTime() < currentDate.getTime()) {
            break;
        }
    }

    return streak;
}

function loadTodayMood() {
    const today = formatDate(new Date());
    const todayEntry = diaryEntries.find(entry => entry.date === today);
    
    const moodDisplay = document.getElementById('todayMood');
    if (!moodDisplay) return;

    if (todayEntry) {
        moodDisplay.innerHTML = `
            <div class="mood-emoji">${todayEntry.emoji}</div>
            <div class="mood-text">${getMoodText(todayEntry.mood)}</div>
        `;
    } else {
        moodDisplay.innerHTML = `
            <div class="mood-emoji">😐</div>
            <div class="mood-text">還沒記錄</div>
        `;
    }
}

// 寫日記頁面功能
function initializeWritePage() {
    const today = new Date().toISOString().split('T')[0];
    const dateInput = document.getElementById('entryDate');
    dateInput.value = today;
    
    // 更新日期顯示
    updateDateDisplay(today);

    // 日期輸入變更監聽
    dateInput.addEventListener('change', function() {
        updateDateDisplay(this.value);
    });

    // 心情選擇
    document.querySelectorAll('.mood-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.mood-btn').forEach(b => b.classList.remove('selected'));
            this.classList.add('selected');
            document.getElementById('selectedMood').value = this.dataset.mood;
            document.getElementById('selectedEmoji').value = this.dataset.emoji;
        });
    });

    // 天氣選擇
    document.querySelectorAll('.weather-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.weather-btn').forEach(b => b.classList.remove('selected'));
            this.classList.add('selected');
            document.getElementById('selectedWeather').value = this.dataset.weather;
        });
    });

    // 表單提交
    document.getElementById('diaryForm').addEventListener('submit', function(e) {
        e.preventDefault();
        saveDiaryEntry();
    });

    // 檢查是否是編輯模式
    const urlParams = new URLSearchParams(window.location.search);
    const editId = urlParams.get('edit');
    if (editId) {
        loadEntryForEdit(editId);
    }
}

function saveDiaryEntry() {
    const formData = new FormData(document.getElementById('diaryForm'));
    const entryData = {
        date: formData.get('date'),
        title: formData.get('title'),
        content: formData.get('content'),
        mood: formData.get('mood'),
        emoji: formData.get('emoji'),
        weather: formData.get('weather'),
        tags: formData.get('tags') ? formData.get('tags').split(',').map(tag => tag.trim()).filter(tag => tag) : []
    };

    // 驗證必填欄位
    if (!entryData.content.trim()) {
        alert('請輸入日記內容');
        return;
    }

    const urlParams = new URLSearchParams(window.location.search);
    const editId = urlParams.get('edit');

    if (editId) {
        // 編輯現有日記
        const entryIndex = diaryEntries.findIndex(entry => entry.id === editId);
        if (entryIndex !== -1) {
            diaryEntries[entryIndex] = {
                ...diaryEntries[entryIndex],
                ...entryData,
                modifiedAt: new Date().toISOString()
            };
        }
    } else {
        // 新增日記
        const newEntry = {
            id: generateId(),
            ...entryData,
            createdAt: new Date().toISOString(),
            modifiedAt: new Date().toISOString()
        };
        diaryEntries.push(newEntry);
    }

    saveDiaryEntries();
    alert('日記已儲存！');
    window.location.href = 'index.html';
}

function loadEntryForEdit(entryId) {
    const entry = diaryEntries.find(e => e.id === entryId);
    if (!entry) return;

    document.getElementById('entryDate').value = entry.date;
    document.getElementById('entryTitle').value = entry.title || '';
    document.getElementById('entryContent').value = entry.content;
    document.getElementById('entryTags').value = entry.tags ? entry.tags.join(', ') : '';

    // 設定心情
    document.getElementById('selectedMood').value = entry.mood;
    document.getElementById('selectedEmoji').value = entry.emoji;
    document.querySelectorAll('.mood-btn').forEach(btn => {
        btn.classList.toggle('selected', btn.dataset.mood === entry.mood);
    });

    // 設定天氣
    if (entry.weather) {
        document.getElementById('selectedWeather').value = entry.weather;
        document.querySelectorAll('.weather-btn').forEach(btn => {
            btn.classList.toggle('selected', btn.dataset.weather === entry.weather);
        });
    }

    // 更新標題
    document.querySelector('.page-header h1').textContent = '編輯日記';
}

// 日記列表頁面功能
function initializeDiaryListPage() {
    loadDiaryList();
    setupSearch();
    setupFilters();
}

function loadDiaryList(filteredEntries = null) {
    const container = document.getElementById('diaryEntries');
    const emptyState = document.getElementById('emptyState');
    const noResults = document.getElementById('noResults');

    if (!container) return;

    const entriesToShow = filteredEntries || diaryEntries;
    const sortedEntries = entriesToShow.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    // 隱藏所有狀態
    if (emptyState) emptyState.style.display = 'none';
    if (noResults) noResults.style.display = 'none';

    if (sortedEntries.length === 0) {
        container.innerHTML = '';
        if (filteredEntries === null) {
            // 沒有任何日記
            if (emptyState) emptyState.style.display = 'block';
        } else {
            // 沒有搜尋結果
            if (noResults) noResults.style.display = 'block';
        }
        return;
    }

    container.innerHTML = sortedEntries.map(entry => `
        <div class="diary-card" onclick="viewEntry('${entry.id}')">
            <div class="diary-header">
                <div class="diary-date">${formatDisplayDate(entry.date)}</div>
                <div class="diary-mood">
                    <span class="diary-mood-emoji">${entry.emoji}</span>
                    <span class="mood-text">${getMoodText(entry.mood)}</span>
                </div>
            </div>
            ${entry.title ? `<div class="diary-title">${entry.title}</div>` : ''}
            <div class="diary-preview">${entry.content.substring(0, 150)}${entry.content.length > 150 ? '...' : ''}</div>
            ${entry.weather ? `<div class="entry-weather">${getWeatherEmoji(entry.weather)}</div>` : ''}
            ${entry.tags && entry.tags.length > 0 ? `
                <div class="diary-tags">
                    ${entry.tags.map(tag => `<span class="tag">${tag}</span>`).join('')}
                </div>
            ` : ''}
        </div>
    `).join('');
}

function setupSearch() {
    const searchBtn = document.getElementById('searchBtn');
    const searchBar = document.getElementById('searchBar');
    const searchInput = document.getElementById('searchInput');
    const clearSearch = document.getElementById('clearSearch');

    if (!searchBtn || !searchBar || !searchInput) return;

    searchBtn.addEventListener('click', function() {
        searchBar.style.display = searchBar.style.display === 'none' ? 'flex' : 'none';
        if (searchBar.style.display === 'flex') {
            searchInput.focus();
        }
    });

    clearSearch.addEventListener('click', function() {
        searchInput.value = '';
        loadDiaryList();
        searchBar.style.display = 'none';
    });

    searchInput.addEventListener('input', function() {
        const query = this.value.toLowerCase().trim();
        if (query === '') {
            loadDiaryList();
            return;
        }

        const filteredEntries = diaryEntries.filter(entry => 
            entry.content.toLowerCase().includes(query) ||
            (entry.title && entry.title.toLowerCase().includes(query)) ||
            (entry.tags && entry.tags.some(tag => tag.toLowerCase().includes(query)))
        );

        loadDiaryList(filteredEntries);
    });
}

function setupFilters() {
    // 時間篩選
    document.querySelectorAll('.filter-tab').forEach(tab => {
        tab.addEventListener('click', function() {
            document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            applyFilters();
        });
    });

    // 心情篩選
    const moodFilter = document.getElementById('moodFilter');
    if (moodFilter) {
        moodFilter.addEventListener('change', applyFilters);
    }
}

function applyFilters() {
    const activeTimeFilter = document.querySelector('.filter-tab.active')?.dataset.filter;
    const moodFilter = document.getElementById('moodFilter')?.value;

    let filteredEntries = [...diaryEntries];

    // 時間篩選
    if (activeTimeFilter === 'this-month') {
        const currentMonth = new Date().getMonth();
        const currentYear = new Date().getFullYear();
        filteredEntries = filteredEntries.filter(entry => {
            const entryDate = new Date(entry.date);
            return entryDate.getMonth() === currentMonth && entryDate.getFullYear() === currentYear;
        });
    } else if (activeTimeFilter === 'this-year') {
        const currentYear = new Date().getFullYear();
        filteredEntries = filteredEntries.filter(entry => {
            const entryDate = new Date(entry.date);
            return entryDate.getFullYear() === currentYear;
        });
    }

    // 心情篩選
    if (moodFilter) {
        filteredEntries = filteredEntries.filter(entry => entry.mood === moodFilter);
    }

    loadDiaryList(filteredEntries);
}

// 日曆頁面功能
function initializeCalendarPage() {
    renderCalendar();
    setupCalendarNavigation();
    updateMonthStats();
    updateMoodChart();
}

function renderCalendar() {
    const calendarGrid = document.getElementById('calendarGrid');
    const currentMonthElement = document.getElementById('currentMonth');

    if (!calendarGrid || !currentMonthElement) return;

    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();

    // 更新月份標題
    currentMonthElement.textContent = `${year}年${month + 1}月`;

    // 計算日曆
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    const days = [];
    const current = new Date(startDate);
    
    for (let i = 0; i < 42; i++) {
        days.push(new Date(current));
        current.setDate(current.getDate() + 1);
    }

    // 取得本月的日記
    const monthEntries = diaryEntries.filter(entry => {
        const entryDate = new Date(entry.date);
        return entryDate.getMonth() === month && entryDate.getFullYear() === year;
    });

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    calendarGrid.innerHTML = days.map(day => {
        const dateStr = formatDate(day);
        const hasEntry = monthEntries.some(entry => entry.date === dateStr);
        const isToday = day.getTime() === today.getTime();
        const isCurrentMonth = day.getMonth() === month;

        let classes = ['calendar-day'];
        if (isToday) classes.push('today');
        if (hasEntry) classes.push('has-entry');
        if (!isCurrentMonth) classes.push('other-month');

        return `
            <div class="${classes.join(' ')}" 
                 data-date="${dateStr}" 
                 onclick="selectDate('${dateStr}')"
                 style="${!isCurrentMonth ? 'opacity: 0.3;' : ''}">
                ${day.getDate()}
            </div>
        `;
    }).join('');
}

function setupCalendarNavigation() {
    const prevBtn = document.getElementById('prevMonth');
    const nextBtn = document.getElementById('nextMonth');
    const todayBtn = document.getElementById('todayBtn');

    if (prevBtn) {
        prevBtn.addEventListener('click', function() {
            currentDate.setMonth(currentDate.getMonth() - 1);
            renderCalendar();
            updateMonthStats();
            updateMoodChart();
        });
    }

    if (nextBtn) {
        nextBtn.addEventListener('click', function() {
            currentDate.setMonth(currentDate.getMonth() + 1);
            renderCalendar();
            updateMonthStats();
            updateMoodChart();
        });
    }

    if (todayBtn) {
        todayBtn.addEventListener('click', function() {
            currentDate = new Date();
            renderCalendar();
            updateMonthStats();
            updateMoodChart();
        });
    }
}

function selectDate(dateStr) {
    // 移除之前的選擇
    document.querySelectorAll('.calendar-day').forEach(day => {
        day.classList.remove('selected');
    });

    // 選擇新的日期
    const selectedDay = document.querySelector(`[data-date="${dateStr}"]`);
    if (selectedDay) {
        selectedDay.classList.add('selected');
    }

    // 顯示該日期的日記
    showDateEntries(dateStr);
}

function showDateEntries(dateStr) {
    const section = document.getElementById('selectedDateEntries');
    const title = document.getElementById('selectedDateTitle');
    const container = document.getElementById('dateEntries');

    if (!section || !title || !container) return;

    const entries = diaryEntries.filter(entry => entry.date === dateStr);
    
    if (entries.length === 0) {
        section.style.display = 'none';
        return;
    }

    const displayDate = formatDisplayDate(dateStr);
    title.textContent = `${displayDate} 的日記`;

    container.innerHTML = entries.map(entry => `
        <div class="diary-card" onclick="viewEntry('${entry.id}')">
            <div class="diary-header">
                <div class="diary-mood">
                    <span class="diary-mood-emoji">${entry.emoji}</span>
                    <span class="mood-text">${getMoodText(entry.mood)}</span>
                </div>
            </div>
            ${entry.title ? `<div class="diary-title">${entry.title}</div>` : ''}
            <div class="diary-preview">${entry.content.substring(0, 100)}${entry.content.length > 100 ? '...' : ''}</div>
        </div>
    `).join('');

    section.style.display = 'block';
}

function updateMonthStats() {
    const monthEntriesElement = document.getElementById('monthEntries');
    const monthMoodElement = document.getElementById('monthMood');
    const monthStreakElement = document.getElementById('monthStreak');

    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();

    const monthEntries = diaryEntries.filter(entry => {
        const entryDate = new Date(entry.date);
        return entryDate.getMonth() === month && entryDate.getFullYear() === year;
    });

    if (monthEntriesElement) {
        monthEntriesElement.textContent = monthEntries.length;
    }

    if (monthMoodElement && monthEntries.length > 0) {
        const moodCounts = {};
        monthEntries.forEach(entry => {
            moodCounts[entry.mood] = (moodCounts[entry.mood] || 0) + 1;
        });

        const mostCommonMood = Object.keys(moodCounts).reduce((a, b) => 
            moodCounts[a] > moodCounts[b] ? a : b
        );

        const moodEmojis = {
            'very-sad': '😢',
            'sad': '😔',
            'neutral': '😐',
            'happy': '😊',
            'very-happy': '😆',
            'love': '🥰'
        };

        monthMoodElement.textContent = moodEmojis[mostCommonMood] || '😐';
    }

    if (monthStreakElement) {
        monthStreakElement.textContent = calculateMonthStreak(year, month);
    }
}

function calculateMonthStreak(year, month) {
    const monthEntries = diaryEntries
        .filter(entry => {
            const entryDate = new Date(entry.date);
            return entryDate.getMonth() === month && entryDate.getFullYear() === year;
        })
        .map(entry => entry.date)
        .sort();

    if (monthEntries.length === 0) return 0;

    let maxStreak = 1;
    let currentStreak = 1;

    for (let i = 1; i < monthEntries.length; i++) {
        const prevDate = new Date(monthEntries[i - 1]);
        const currentDate = new Date(monthEntries[i]);
        const diffDays = (currentDate - prevDate) / (1000 * 60 * 60 * 24);

        if (diffDays === 1) {
            currentStreak++;
            maxStreak = Math.max(maxStreak, currentStreak);
        } else {
            currentStreak = 1;
        }
    }

    return maxStreak;
}

function updateMoodChart() {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();

    const monthEntries = diaryEntries.filter(entry => {
        const entryDate = new Date(entry.date);
        return entryDate.getMonth() === month && entryDate.getFullYear() === year;
    });

    const moodCounts = {
        'very-happy': 0,
        'happy': 0,
        'neutral': 0,
        'sad': 0,
        'very-sad': 0
    };

    monthEntries.forEach(entry => {
        if (moodCounts.hasOwnProperty(entry.mood)) {
            moodCounts[entry.mood]++;
        }
    });

    const maxCount = Math.max(...Object.values(moodCounts), 1);

    document.querySelectorAll('.mood-bar').forEach(bar => {
        const mood = bar.dataset.mood;
        const count = moodCounts[mood] || 0;
        const percentage = (count / maxCount) * 100;

        const barElement = bar.querySelector('.bar');
        const countElement = bar.querySelector('.mood-count');

        if (barElement) barElement.style.width = `${percentage}%`;
        if (countElement) countElement.textContent = count;
    });
}

// 閱讀頁面功能
function initializeReadPage() {
    const urlParams = new URLSearchParams(window.location.search);
    const entryId = urlParams.get('id');

    if (entryId) {
        loadEntry(entryId);
        setupReadPageActions(entryId);
    }
}

function loadEntry(entryId) {
    const entry = diaryEntries.find(e => e.id === entryId);
    if (!entry) {
        alert('找不到該日記');
        window.history.back();
        return;
    }

    // 更新頁面內容
    document.getElementById('entryDate').textContent = formatDisplayDate(entry.date);
    document.getElementById('entryMoodEmoji').textContent = entry.emoji;
    document.getElementById('entryMoodText').textContent = getMoodText(entry.mood);

    if (entry.title) {
        document.getElementById('entryTitle').textContent = entry.title;
        document.getElementById('entryTitle').style.display = 'block';
    } else {
        document.getElementById('entryTitle').style.display = 'none';
    }

    document.getElementById('entryContent').innerHTML = entry.content.replace(/\n/g, '<br>');

    if (entry.weather) {
        const weatherElement = document.getElementById('entryWeather');
        weatherElement.querySelector('.weather-emoji').textContent = getWeatherEmoji(entry.weather);
        weatherElement.style.display = 'block';
    }

    if (entry.tags && entry.tags.length > 0) {
        const tagsElement = document.getElementById('entryTags');
        tagsElement.innerHTML = entry.tags.map(tag => `<span class="tag">${tag}</span>`).join('');
        tagsElement.style.display = 'block';
    }

    // 更新元數據
    const wordCount = entry.content.length;
    document.getElementById('entryWordCount').textContent = `${wordCount} 字`;

    const createdDate = new Date(entry.createdAt);
    document.getElementById('entryCreatedTime').textContent = 
        `建立於 ${createdDate.toLocaleDateString('zh-TW')} ${createdDate.toLocaleTimeString('zh-TW', { hour: '2-digit', minute: '2-digit' })}`;

    if (entry.modifiedAt && entry.modifiedAt !== entry.createdAt) {
        const modifiedDate = new Date(entry.modifiedAt);
        const modifiedElement = document.getElementById('entryModifiedTime');
        modifiedElement.textContent = 
            `最後編輯 ${modifiedDate.toLocaleDateString('zh-TW')} ${modifiedDate.toLocaleTimeString('zh-TW', { hour: '2-digit', minute: '2-digit' })}`;
        modifiedElement.style.display = 'block';
    }

    // 設定編輯連結
    document.getElementById('editLink').href = `write.html?edit=${entryId}`;
}

function setupReadPageActions(entryId) {
    // 編輯按鈕
    document.getElementById('editBtn').addEventListener('click', function() {
        window.location.href = `write.html?edit=${entryId}`;
    });

    // 刪除按鈕
    document.getElementById('deleteBtn').addEventListener('click', function() {
        document.getElementById('deleteModal').style.display = 'flex';
    });

    // 刪除確認
    document.getElementById('confirmDelete').addEventListener('click', function() {
        deleteEntry(entryId);
    });

    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').style.display = 'none';
    });

    // 分享按鈕
    document.getElementById('shareBtn').addEventListener('click', function() {
        document.getElementById('shareModal').style.display = 'flex';
    });

    document.getElementById('closeShareModal').addEventListener('click', function() {
        document.getElementById('shareModal').style.display = 'none';
    });

    // 分享選項
    document.querySelectorAll('.share-option').forEach(option => {
        option.addEventListener('click', function() {
            const type = this.dataset.type;
            shareEntry(entryId, type);
        });
    });

    // 收藏按鈕 (暫時只是視覺效果)
    document.getElementById('favoriteBtn').addEventListener('click', function() {
        this.classList.toggle('active');
        this.textContent = this.classList.contains('active') ? '已收藏' : '收藏';
    });
}

function deleteEntry(entryId) {
    const entryIndex = diaryEntries.findIndex(entry => entry.id === entryId);
    if (entryIndex !== -1) {
        diaryEntries.splice(entryIndex, 1);
        saveDiaryEntries();
        alert('日記已刪除');
        window.location.href = 'diary-list.html';
    }
}

function shareEntry(entryId, type) {
    const entry = diaryEntries.find(e => e.id === entryId);
    if (!entry) return;

    let shareText = `${formatDisplayDate(entry.date)}\n心情：${entry.emoji} ${getMoodText(entry.mood)}\n\n`;
    if (entry.title) shareText += `${entry.title}\n\n`;
    shareText += entry.content;

    if (type === 'text') {
        if (navigator.share) {
            navigator.share({
                title: '我的日記',
                text: shareText
            });
        } else {
            navigator.clipboard.writeText(shareText).then(() => {
                alert('日記內容已複製到剪貼簿');
            });
        }
    } else if (type === 'image') {
        // 實際實作需要 canvas 生成圖片
        alert('圖片分享功能開發中');
    } else if (type === 'pdf') {
        // 實際實作需要 PDF 生成庫
        alert('PDF 匯出功能開發中');
    }

    document.getElementById('shareModal').style.display = 'none';
}

// 設定頁面功能
function initializeSettingsPage() {
    loadSettingsUI();
    setupSettingsHandlers();
}

function loadSettingsUI() {
    // 載入設定值到 UI
    document.getElementById('darkModeToggle').checked = settings.darkMode;
    document.getElementById('reminderToggle').checked = settings.reminderEnabled;
    document.getElementById('moodAnalysisToggle').checked = settings.moodAnalysis;
    document.getElementById('fontSizeSelect').value = settings.fontSize;

    // 更新主題顏色
    document.querySelectorAll('.color-option').forEach(option => {
        option.classList.toggle('active', option.dataset.theme === settings.theme);
    });
}

function setupSettingsHandlers() {
    // 深色模式切換
    document.getElementById('darkModeToggle').addEventListener('change', function() {
        settings.darkMode = this.checked;
        saveSettings();
        applyTheme();
    });

    // 提醒切換
    document.getElementById('reminderToggle').addEventListener('change', function() {
        settings.reminderEnabled = this.checked;
        saveSettings();
    });

    // 心情分析切換
    document.getElementById('moodAnalysisToggle').addEventListener('change', function() {
        settings.moodAnalysis = this.checked;
        saveSettings();
    });

    // 字體大小
    document.getElementById('fontSizeSelect').addEventListener('change', function() {
        settings.fontSize = this.value;
        saveSettings();
        applyTheme();
    });

    // 主題顏色
    document.querySelectorAll('.color-option').forEach(option => {
        option.addEventListener('click', function() {
            document.querySelectorAll('.color-option').forEach(opt => opt.classList.remove('active'));
            this.classList.add('active');
            settings.theme = this.dataset.theme;
            saveSettings();
            applyTheme();
        });
    });
}

// 主題應用
function applyTheme() {
    const body = document.body;
    
    // 移除現有的主題類別
    body.className = body.className.replace(/font-\w+|theme-\w+/g, '');
    
    // 應用字體大小
    if (settings.fontSize !== 'medium') {
        body.classList.add(`font-${settings.fontSize}`);
    }
    
    // 應用主題顏色
    if (settings.theme !== 'default') {
        body.classList.add(`theme-${settings.theme}`);
    }
    
    // 應用深色模式
    if (settings.darkMode) {
        body.setAttribute('data-theme', 'dark');
    } else {
        body.removeAttribute('data-theme');
    }
}

// 設定功能函數
function editNickname() {
    const newNickname = prompt('輸入新的暱稱:', settings.nickname || '我的日記');
    if (newNickname && newNickname.trim()) {
        settings.nickname = newNickname.trim();
        document.getElementById('userNickname').textContent = settings.nickname;
        saveSettings();
    }
}

function changeAvatar() {
    alert('頭像更換功能開發中');
}

function setReminderTime() {
    const newTime = prompt('設定提醒時間 (格式: HH:MM):', settings.reminderTime);
    if (newTime && /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/.test(newTime)) {
        settings.reminderTime = newTime;
        document.getElementById('reminderTime').textContent = `每天 ${newTime}`;
        saveSettings();
    } else if (newTime) {
        alert('時間格式錯誤，請使用 HH:MM 格式');
    }
}

function exportData() {
    const exportData = {
        entries: diaryEntries,
        settings: settings,
        exportDate: new Date().toISOString()
    };

    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);

    const link = document.createElement('a');
    link.href = url;
    link.download = `diary-backup-${formatDate(new Date())}.json`;
    link.click();

    URL.revokeObjectURL(url);
}

function importData() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    
    input.addEventListener('change', function(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(e) {
            try {
                const importData = JSON.parse(e.target.result);
                
                if (importData.entries && Array.isArray(importData.entries)) {
                    const confirmed = confirm(`確定要匯入 ${importData.entries.length} 筆日記嗎？這將覆蓋現有資料。`);
                    if (confirmed) {
                        diaryEntries = importData.entries;
                        if (importData.settings) {
                            settings = { ...settings, ...importData.settings };
                        }
                        saveDiaryEntries();
                        saveSettings();
                        alert('資料匯入成功！');
                        location.reload();
                    }
                } else {
                    alert('檔案格式錯誤');
                }
            } catch (error) {
                alert('檔案讀取失敗');
            }
        };
        reader.readAsText(file);
    });
    
    input.click();
}

function clearAllData() {
    const confirmed = confirm('確定要清除所有資料嗎？此操作無法復原。');
    if (confirmed) {
        const doubleConfirm = confirm('再次確認：這將永久刪除所有日記和設定，確定要繼續嗎？');
        if (doubleConfirm) {
            localStorage.removeItem('diaryEntries');
            localStorage.removeItem('diarySettings');
            alert('所有資料已清除');
            location.reload();
        }
    }
}

function showHelp() {
    alert('使用說明功能開發中');
}

function sendFeedback() {
    alert('意見回饋功能開發中');
}

// 通用功能
function viewEntry(entryId) {
    window.location.href = `read.html?id=${entryId}`;
}

// 點擊對話框外部關閉
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal')) {
        e.target.style.display = 'none';
    }
});

// 日期處理函數
let selectedDate = null;
let pickerCurrentDate = new Date();

function updateDateDisplay(dateString) {
    const dateDisplay = document.getElementById('dateText');
    if (!dateDisplay || !dateString) return;

    const date = new Date(dateString);
    const formattedDate = date.toLocaleDateString('zh-TW', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long'
    });
    
    dateDisplay.textContent = formattedDate;
}

function openDatePicker() {
    const dateInput = document.getElementById('entryDate');
    if (dateInput) {
        dateInput.focus();
        dateInput.click();
    }
}

// 自定義日曆選擇器功能
function openCustomDatePicker() {
    const datePicker = document.getElementById('customDatePicker');
    if (!datePicker) return;

    // 創建背景遮罩
    const overlay = document.createElement('div');
    overlay.className = 'date-picker-overlay';
    overlay.onclick = closeDatePicker;
    document.body.appendChild(overlay);

    // 初始化當前選中的日期
    const currentValue = document.getElementById('entryDate').value;
    if (currentValue) {
        selectedDate = new Date(currentValue);
        pickerCurrentDate = new Date(selectedDate);
    } else {
        selectedDate = new Date();
        pickerCurrentDate = new Date();
    }

    renderDatePicker();
    datePicker.style.display = 'block';

    // 設置導航按鈕事件
    setupDatePickerNavigation();
}

function closeDatePicker() {
    const datePicker = document.getElementById('customDatePicker');
    const overlay = document.querySelector('.date-picker-overlay');
    
    if (datePicker) datePicker.style.display = 'none';
    if (overlay) overlay.remove();
}

function renderDatePicker() {
    const grid = document.getElementById('datePickerGrid');
    const monthYearElement = document.getElementById('currentMonthYear');
    
    if (!grid || !monthYearElement) return;

    const year = pickerCurrentDate.getFullYear();
    const month = pickerCurrentDate.getMonth();

    // 更新月份年份顯示
    monthYearElement.textContent = `${year}年${month + 1}月`;

    // 計算日曆網格
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay());

    const days = [];
    const current = new Date(startDate);
    
    for (let i = 0; i < 42; i++) {
        days.push(new Date(current));
        current.setDate(current.getDate() + 1);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    grid.innerHTML = days.map(day => {
        const isCurrentMonth = day.getMonth() === month;
        const isToday = day.getTime() === today.getTime();
        const isSelected = selectedDate && day.getTime() === selectedDate.getTime();

        let classes = ['date-picker-day'];
        if (isToday) classes.push('today');
        if (isSelected) classes.push('selected');
        if (!isCurrentMonth) classes.push('other-month');

        return `
            <div class="${classes.join(' ')}" 
                 data-date="${formatDate(day)}"
                 onclick="selectDateInPicker('${formatDate(day)}')">
                ${day.getDate()}
            </div>
        `;
    }).join('');
}

function selectDateInPicker(dateString) {
    selectedDate = new Date(dateString);
    
    // 更新選中狀態
    document.querySelectorAll('.date-picker-day').forEach(day => {
        day.classList.remove('selected');
    });
    
    const selectedElement = document.querySelector(`[data-date="${dateString}"]`);
    if (selectedElement) {
        selectedElement.classList.add('selected');
    }
}

function confirmDateSelection() {
    if (selectedDate) {
        const dateInput = document.getElementById('entryDate');
        const dateString = formatDate(selectedDate);
        
        dateInput.value = dateString;
        updateDateDisplay(dateString);
    }
    
    closeDatePicker();
}

function setupDatePickerNavigation() {
    const prevBtn = document.getElementById('prevMonthBtn');
    const nextBtn = document.getElementById('nextMonthBtn');

    if (prevBtn) {
        prevBtn.onclick = function() {
            pickerCurrentDate.setMonth(pickerCurrentDate.getMonth() - 1);
            renderDatePicker();
        };
    }

    if (nextBtn) {
        nextBtn.onclick = function() {
            pickerCurrentDate.setMonth(pickerCurrentDate.getMonth() + 1);
            renderDatePicker();
        };
    }
}

// 鍵盤快捷鍵
document.addEventListener('keydown', function(e) {
    // Ctrl/Cmd + N: 新增日記
    if ((e.ctrlKey || e.metaKey) && e.key === 'n') {
        e.preventDefault();
        window.location.href = 'write.html';
    }
    
    // ESC: 關閉對話框
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal').forEach(modal => {
            modal.style.display = 'none';
        });
    }
});