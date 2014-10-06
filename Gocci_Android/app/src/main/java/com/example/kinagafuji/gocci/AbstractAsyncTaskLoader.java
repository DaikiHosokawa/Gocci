package com.example.kinagafuji.gocci;

import android.content.Context;
import android.support.v4.content.AsyncTaskLoader;


public abstract class AbstractAsyncTaskLoader<T> extends AsyncTaskLoader<T> {

    protected T result;

    public AbstractAsyncTaskLoader(Context context) {
        super(context);
    }

    @Override
    abstract public T loadInBackground();

    @Override
    public void deliverResult(T data) {
        if (isReset()) {
            return;
        }

        result = data;
        if (isStarted()) {
            super.deliverResult(data);
        }
    }

    @Override
    protected void onStartLoading() {
        if (result != null) {
            deliverResult(result);
        }

        if (takeContentChanged() || result == null) {
            forceLoad(); // 非同期処理を開始
        }
    }

    @Override
    protected void onStopLoading() {
        cancelLoad(); // 非同期処理のキャンセル
    }

    @Override
    public void onCanceled(T data) {
        // 特にやることなし
    }

    @Override
    protected void onReset() {
        super.onReset();

        onStopLoading();
        result = null;
    }


}
