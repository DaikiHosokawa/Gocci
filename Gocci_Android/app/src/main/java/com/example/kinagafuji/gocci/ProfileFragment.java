package com.example.kinagafuji.gocci;


import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

public class ProfileFragment extends BaseFragment {

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // FragmentのViewを返却
        View rootView = inflater.inflate(R.layout.fragment_profile, container, false);

        return rootView;
    }
}
