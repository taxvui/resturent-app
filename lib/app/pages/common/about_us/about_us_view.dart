import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_pos/i18n/strings.g.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/repository/repository.dart';
import '../../../widgets/widgets.dart';

@RoutePage()
class AboutUsView extends ConsumerWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _aboutUsAsync = ref.watch(_aboutUsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.t.pages.aboutUs.title),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () => ref.refresh(_aboutUsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: _aboutUsAsync.when(
            skipLoadingOnRefresh: false,
            data: (data) {
              return HtmlWidget(
                data.data?.value?.description ?? '',
                onLoadingBuilder: (_, _, _) {
                  return _buildPlaceholder;
                },
              );
            },
            error: (error, _) {
              return EmptyWidget(
                replaceDefault: false,
                emptyBuilder: (context) {
                  return RetryButtons.scrollView(
                    error,
                    onRetry: () => ref.refresh(_aboutUsProvider),
                  );
                },
              );
            },
            loading: () => _buildPlaceholder,
          ),
        ),
      ),
    );
  }

  Widget get _buildPlaceholder {
    return Skeletonizer(
      child: HtmlWidget(
        '''
 <h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
<p>
    A paragraph with <strong>strong</strong>, <em>emphasized</em>
    and <span style="color: red">colored</span> text.
</p>
<h3>Heading</h3>
  ''',
      ),
    );
  }
}

final _aboutUsProvider = FutureProvider<SummerNoteModel>(
  (ref) => Future.microtask(ref.read(commonRepoProvider).getAboutUs),
);
