package com.example.kinagafuji.gocci;

import android.app.Activity;
import android.app.Fragment;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.ViewPager;
import android.util.TypedValue;
import android.view.Menu;
import android.view.MenuItem;

import com.example.kinagafuji.gocci.data.PageItem;


public class PagerTabStripActivity extends FragmentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pager_tab_strip);

        ViewPager pager = (ViewPager) findViewById(R.id.pager);

        // PagerTitleStrip のカスタマイズ
        PagerTabStrip strip = (PagerTabStrip) findViewById(R.id.strip);
        strip.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        strip.setTextColor(0xff9acd32);
        strip.setTextSpacing(25);
        strip.setNonPrimaryAlpha(0.3f);
        strip.setDrawFullUnderline(true);
        strip.setTabIndicatorColor(0xff9acd32);

        // ViewPager の Adapter
        CustomFragmentPagerAdapter adapter = new CustomFragmentPagerAdapter(getSupportFragmentManager());

        PageItem timeline = new PageItem();
        timeline.title = "タイムライン";
        timeline.fragmentKind = PageItem.TIMELINE;
        adapter.addItem(timeline);

        PageItem search = new PageItem();
        search.title = "検索";
        search.fragmentKind = PageItem.SEARCH;
        adapter.addItem(search);

        PageItem profile = new PageItem();
        profile.title = "プロフィール";
        profile.fragmentKind = PageItem.PROFILE;
        adapter.addItem(profile);

        PageItem lifelog = new PageItem();
        lifelog.title = "プロフィール";
        lifelog.fragmentKind = PageItem.LIFELOG;
        adapter.addItem(lifelog);

        pager.setAdapter(adapter);

    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.pager_tab_strip, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
