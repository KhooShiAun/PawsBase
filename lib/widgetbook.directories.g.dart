// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:pawsbase/views/health_log/health_log_page.stories.dart'
    as _pawsbase_views_health_log_health_log_page_stories;
import 'package:pawsbase/views/settings/settings_page.stories.dart'
    as _pawsbase_views_settings_settings_page_stories;
import 'package:pawsbase/widgets/paws_bottom_nav/paws_bottom_nav.stories.dart'
    as _pawsbase_widgets_paws_bottom_nav_paws_bottom_nav_stories;
import 'package:pawsbase/widgets/paws_button/paws_button.stories.dart'
    as _pawsbase_widgets_paws_button_paws_button_stories;
import 'package:pawsbase/widgets/paws_card/paws_card.stories.dart'
    as _pawsbase_widgets_paws_card_paws_card_stories;
import 'package:pawsbase/widgets/paws_header/paws_header.stories.dart'
    as _pawsbase_widgets_paws_header_paws_header_stories;
import 'package:pawsbase/widgets/paws_progress_bar/paws_progress_bar.stories.dart'
    as _pawsbase_widgets_paws_progress_bar_paws_progress_bar_stories;
import 'package:pawsbase/widgets/paws_search_bar/paws_search_bar.stories.dart'
    as _pawsbase_widgets_paws_search_bar_paws_search_bar_stories;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'views',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'health_log',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'HealthLogPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _pawsbase_views_health_log_health_log_page_stories
                    .healthLogPageDefaultUseCase,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'settings',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'SettingsPage',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _pawsbase_views_settings_settings_page_stories
                    .settingsPageDefaultUseCase,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  _widgetbook.WidgetbookFolder(
    name: 'widgets',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'paws_bottom_nav',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PawsBottomNav',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _pawsbase_widgets_paws_bottom_nav_paws_bottom_nav_stories
                        .defaultBottomNav,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'paws_button',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PawsButton',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'All Buttons',
                builder: _pawsbase_widgets_paws_button_paws_button_stories
                    .allButtons,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'paws_card',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PawsCard',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _pawsbase_widgets_paws_card_paws_card_stories.defaultCard,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With Image',
                builder:
                    _pawsbase_widgets_paws_card_paws_card_stories.cardWithImage,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'paws_header',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PawsHeader',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _pawsbase_widgets_paws_header_paws_header_stories
                    .defaultHeader,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'With Subtitle and Actions',
                builder: _pawsbase_widgets_paws_header_paws_header_stories
                    .headerWithSubtitle,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'paws_progress_bar',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PawsProgressBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'All Bars',
                builder:
                    _pawsbase_widgets_paws_progress_bar_paws_progress_bar_stories
                        .allProgressBars,
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'paws_search_bar',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'PawsSearchBar',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder:
                    _pawsbase_widgets_paws_search_bar_paws_search_bar_stories
                        .defaultSearchBar,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
