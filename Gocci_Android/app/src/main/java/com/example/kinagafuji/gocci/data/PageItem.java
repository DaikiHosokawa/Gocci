package com.example.kinagafuji.gocci.data;

public class PageItem {

    public static final int TIMELINE = 0;
    public static final int SEARCH = 1;
    public static final int PROFILE = 2;
    public static final int LIFELOG = 3;
    /** ページ名. */
    public String title;
    /** Fragment の種類. */
    public int fragmentKind;
}
