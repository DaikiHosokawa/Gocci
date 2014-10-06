package com.example.kinagafuji.gocci;

import android.animation.Animator;
import android.animation.AnimatorInflater;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.MediaController;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import com.example.kinagafuji.gocci.data.UserData;
import com.squareup.picasso.Picasso;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;

public class TimelineFragment extends BaseFragment {

    private ProgressDialog pDialog;

    static boolean isXLargeScreen = false;

    private SwipeRefreshLayout mSwipeRefreshLayout;

    private static String url = "https://codelecture.com/gocci/timeline.php";
    private static final String TAG_POST_ID = "post_id";
    private static final String TAG_USER_ID = "user_id";
    private static final String TAG_USER_NAME = "user_name";
    private static final String TAG_PICTURE = "picture";
    private static final String TAG_MOVIE = "movie";
    private static final String TAG_RESTNAME = "restname";

    private ArrayList<UserData> users = new ArrayList<UserData>();
    private String data;
    private static boolean isMov = false;

    private ListView mListView;

    private int mCardLayoutIndex = 0;

    public static TimelineFragment newInstance() {
        TimelineFragment fragment = new TimelineFragment();

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // FragmentのViewを返却
        View rootView = inflater.inflate(R.layout.fragment_timeline, container, false);

        isXLargeScreen = isXLargeScreen();
        // SwipeRefreshLayoutの設定
        mSwipeRefreshLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.refresh);
        mSwipeRefreshLayout.setOnRefreshListener(mOnRefreshListener);
        mSwipeRefreshLayout.setColorSchemeColors(Color.GRAY, Color.CYAN, Color.MAGENTA, Color.BLACK);

        mListView = (ListView) rootView.findViewById(R.id.mylistView2);

        final UserAdapter userAdapter = new UserAdapter(getActivity(), 0, users);
        mListView.setDivider(null);
        // スクロールバーを表示しない
        mListView.setVerticalScrollBarEnabled(false);
        // カード部分をselectorにするので、リストのselectorは透明にする
        mListView.setSelector(android.R.color.transparent);

        // 最後の余白分のビューを追加
        if (mCardLayoutIndex > 0) {
            mListView.addFooterView(LayoutInflater.from(getActivity()).inflate(
                    R.layout.card_footer, mListView, false));
        }
        mListView.setAdapter(userAdapter);

        mListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {

                UserData country = users.get(pos);

                Intent intent = new Intent(getActivity().getApplicationContext(), ToukouActivity.class);

                //intent.putExtra("restname", country.getRestname());

                //intent.putExtra("locality", country.getLocality());

                startActivity(intent);
            }

        });

        new UserTask().execute(url);
        pDialog = new ProgressDialog(getActivity());
        pDialog.setMessage("Please wait..");
        pDialog.setIndeterminate(true);
        pDialog.setCancelable(false);
        pDialog.show();

        return rootView;
    }

    public boolean isXLargeScreen() {
        int layout = getResources().getConfiguration().screenLayout;
        return (layout & Configuration.SCREENLAYOUT_SIZE_MASK)
                == Configuration.SCREENLAYOUT_SIZE_XLARGE;
    }

    private SwipeRefreshLayout.OnRefreshListener mOnRefreshListener = new SwipeRefreshLayout.OnRefreshListener() {
        @Override
        public void onRefresh() {
            // 3秒待機
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    mSwipeRefreshLayout.setRefreshing(false);
                }
            }, 3000);
        }
    };

    public class UserTask extends AsyncTask<String, String, Integer> {

        @Override
        protected Integer doInBackground(String... strings) {
            HttpClient httpClient = new DefaultHttpClient();


            StringBuilder uri = new StringBuilder(url);
            HttpGet request = new HttpGet(uri.toString());
            HttpResponse httpResponse = null;

            try {
                httpResponse = httpClient.execute(request);
            } catch (Exception e) {
                Log.d("JSONSampleActivity", "Error Execute");
                Log.d("error", String.valueOf(e));

            }

            int status = httpResponse.getStatusLine().getStatusCode();

            if (HttpStatus.SC_OK == status) {
                try {
                    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                    httpResponse.getEntity().writeTo(outputStream);
                    data = outputStream.toString(); // JSONデータ
                    Log.d("data", data);
                } catch (Exception e) {
                    Log.d("JSONSampleActivity", "Error");
                    Log.d("error", String.valueOf(e));
                }

                try {
                    JSONArray jsonArray = new JSONArray(data);

                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject = jsonArray.getJSONObject(i);

                        String post_id = jsonObject.getString(TAG_POST_ID);
                        String user_id = jsonObject.getString(TAG_USER_ID);
                        String user_name = jsonObject.getString(TAG_USER_NAME);
                        String picture = jsonObject.getString(TAG_PICTURE);
                        String movie = jsonObject.getString(TAG_MOVIE);
                        String restname = jsonObject.getString(TAG_RESTNAME);

                        Log.d("String", post_id + "/" + user_id + "/" + user_name + "/" + picture + "/" + movie + "/" + restname);

                        UserData user = new UserData();

                        //movieとpictureはどうすれば？
                        user.setPost_id(post_id);
                        user.setMovie(movie);
                        user.setPicture(picture);
                        user.setUser_id(user_id);
                        user.setUser_name(user_name);
                        user.setRestname(restname);

                        users.add(user);

                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Log.d("error", String.valueOf(e));
                }
            } else {
                Log.d("JSONSampleActivity", "Status" + status);
            }

            return status;
        }

        @Override
        protected void onPostExecute(Integer result) {
            if (result != null && result == HttpStatus.SC_OK) {
                //ListViewの最読み込み
                mListView.invalidateViews();
            } else {
                //通信失敗した際のエラー処理
                Toast.makeText(getActivity().getApplicationContext(), "タイムラインの取得に失敗しました。", Toast.LENGTH_SHORT).show();
            }
            pDialog.dismiss();
        }
    }

    private static class ViewHolder {
        VideoView movie;
        ImageView picture;
        TextView post_id;
        TextView user_id;
        TextView user_name;
        TextView restname;

        public ViewHolder(View view) {
            this.movie = (VideoView) view.findViewById(R.id.movieView);
            this.picture = (ImageView) view.findViewById(R.id.pictureView);
            this.post_id = (TextView) view.findViewById(R.id.post_id);
            this.user_id = (TextView) view.findViewById(R.id.user_id);
            this.user_name = (TextView) view.findViewById(R.id.user_name);
            this.restname = (TextView) view.findViewById(R.id.restname);
        }
    }

    public class UserAdapter extends ArrayAdapter<UserData> {
        private LayoutInflater layoutInflater;
        int mAnimatedPosition = ListView.INVALID_POSITION;

        public UserAdapter(Context context, int viewResourceId, ArrayList<UserData> users) {
            super(context, viewResourceId, users);
            this.layoutInflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            final ViewHolder viewHolder;
            if (convertView == null) {
                convertView = layoutInflater.inflate(R.layout.timeline, null);
                viewHolder = new ViewHolder(convertView);
                convertView.setTag(viewHolder);
            } else {
                viewHolder = (ViewHolder) convertView.getTag();
            }
            UserData user = this.getItem(position);

            viewHolder.post_id.setText(user.getPost_id());
            viewHolder.user_id.setText(user.getUser_id());
            viewHolder.user_name.setText(user.getUser_name());
            viewHolder.restname.setText(user.getRestname());
            viewHolder.movie.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    viewHolder.movie.start();
                    Log.d("videoview","start");
                }
            });
            viewHolder.movie.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                public void onCompletion(MediaPlayer mp) {
                    isMov = false;
                    viewHolder.movie.setVideoURI(null);
                    viewHolder.movie.requestFocus();
                    Log.d("videoview","setnull");
                    //動画終了
                }
            });
            if (!isMov) {
                isMov = true;

                MediaController mediaController= new MediaController(getContext());
                mediaController.setAnchorView(viewHolder.movie);
                viewHolder.movie.setVideoURI(Uri.parse(user.getMovie()));
                Log.d("videoview","setURL");
            }
            Picasso.with(getContext())
                    .load(user.getPicture())
                    .resize(50, 50)
                    .centerCrop()
                    .into(viewHolder.picture);
            /*try{
                URL url = new URL(user.getPicture());
                InputStream istream = url.openStream();
                Bitmap bitmap = BitmapFactory.decodeStream(istream);
                viewHolder.picture.setImageBitmap(bitmap);
                istream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }*/

            // まだ表示していない位置ならアニメーションする
            if (mAnimatedPosition < position) {
                // XMLからアニメーターを作成
                Animator animator = AnimatorInflater.loadAnimator(getContext(),
                        R.animator.card_slide_in);
                // アニメーションさせるビューをセット
                animator.setTarget(convertView);
                // アニメーションを開始
                animator.start();
                mAnimatedPosition = position;
            }
            return convertView;
        }
    }
}
