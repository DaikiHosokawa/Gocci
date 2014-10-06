package com.example.kinagafuji.gocci;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.util.Log;

import com.example.kinagafuji.gocci.data.PageItem;

import java.util.ArrayList;

public class CustomFragmentPagerAdapter extends FragmentPagerAdapter {

    private ArrayList<PageItem> mList;

    public CustomFragmentPagerAdapter(FragmentManager fm) {
        super(fm);
        mList = new ArrayList<PageItem>();
    }

    @Override
    public Fragment getItem(int position) {
        PageItem item = mList.get(position);
        if (PageItem.TIMELINE == item.fragmentKind) {

            return new TimelineFragment();
        } else if (PageItem.SEARCH == item.fragmentKind) {

            return new Search_mapFragment();
        } else if (PageItem.PROFILE == item.fragmentKind) {

            return new ProfileFragment();
        } else if (PageItem.LIFELOG == item.fragmentKind) {
            LifelogFragment lifelogFragment = new LifelogFragment();
            return lifelogFragment;
        } else {
            Log.e("フラグメントエラー","対象のフラグメントがありません。");
            return null;
        }
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return mList.get(position).title;
    }

    @Override
    public int getCount() {
        return mList.size();
    }

    public void addItem(PageItem item) {
        mList.add(item);
    }
}
