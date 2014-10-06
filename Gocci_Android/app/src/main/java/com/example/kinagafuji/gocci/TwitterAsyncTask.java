package com.example.kinagafuji.gocci;

import android.os.AsyncTask;

import twitter4j.TwitterException;

public class TwitterAsyncTask<Params, Progress, Result> extends AsyncTask<Params, Progress, TwitterResult<Result>> {

    private TwitterPreExecute mPreExecute;
    private TwitterAction<TwitterResult<Result>, Params> mAction;
    private TwitterCallback<Result> mCallback;
    private TwitterOnError mOnError;


    public TwitterAsyncTask(TwitterPreExecute preExecute
            , TwitterAction<TwitterResult<Result>, Params> action
            , TwitterCallback<Result> callback
            , TwitterOnError onError) {

        this.mPreExecute = preExecute;
        this.mAction = action;
        this.mCallback = callback;
        this.mOnError = onError;
    }

    @Override
    protected void onPreExecute() {
        mPreExecute.run();
    }

    @Override
    protected TwitterResult<Result> doInBackground(Params... param) {
        return mAction.run(param[0]);
    }

    @Override
    protected void onPostExecute(TwitterResult<Result> result) {
        if(!result.hasError()) {
            mCallback.run(result.getResult());
        } else {
            mOnError.run(result.getError());
        }
    }

    /**
     * onPreExecuteの処理を委譲する
     */
    public static interface TwitterPreExecute {
        public void run();
    }

    /**
     * doInBackgroundの処理を委譲する
     * @param <Result>
     * @param <Params>
     */
    public static interface TwitterAction<Result, Params> {
        public Result run(Params param);
    }

    /**
     * onPostExecuteの処理を委譲する
     * @param <Result>
     */
    public static interface TwitterCallback<Result> {
        public void run(Result result);
    }

    /**
     * TwitterExceptionが発生した時の処理を委譲する
     */
    public static interface TwitterOnError {
        public void run(TwitterException e);
    }
}
