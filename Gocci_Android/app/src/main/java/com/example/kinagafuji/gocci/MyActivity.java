package com.example.kinagafuji.gocci;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.StrictMode;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.VideoView;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;

public class MyActivity extends Activity {

    ProgressDialog pDialog;

    static boolean isXLargeScreen = false;

    private SwipeRefreshLayout mSwipeRefreshLayout;

    private static String url = "https://codelecture.com/gocci/timeline.php";
    private static final String TAG_POST_ID = "post_id";
    private static final String TAG_USER_ID = "user_id";
    private static final String TAG_USER_NAME = "user_name";
    private static final String TAG_PICTURE = "picture";
    private static final String TAG_MOVIE = "movie";
    private static final String TAG_RESTNAME = "restname";

    private ArrayList<User> users = new ArrayList<User>();
    private String data;
    private static boolean isMov = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my);

        StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder().detectAll().penaltyLog().build());
        isXLargeScreen = isXLargeScreen();
        // SwipeRefreshLayoutの設定
        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.refresh);
        mSwipeRefreshLayout.setOnRefreshListener(mOnRefreshListener);
        mSwipeRefreshLayout.setColorSchemeColors(Color.GRAY, Color.CYAN, Color.MAGENTA, Color.BLACK);

        new UserTask().execute(url);
        pDialog = new ProgressDialog(this);
        pDialog.setMessage("Please wait..");
        pDialog.setIndeterminate(true);
        pDialog.setCancelable(false);
        pDialog.show();
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

    public class UserTask extends AsyncTask<String, String, String> {


        @Override
        protected String doInBackground(String... strings) {
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

                        User user = new User();

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

            return data;
        }

        @Override
        protected void onPostExecute(String result) {
            pDialog.dismiss();

            final UserAdapter userAdapter = new UserAdapter(MyActivity.this, 0, users);
            ListView lv = (ListView) findViewById(R.id.mylistView2);
            lv.setDivider(null);
            // スクロールバーを表示しない
            lv.setVerticalScrollBarEnabled(false);
            // カード部分をselectorにするので、リストのselectorは透明にする
            lv.setSelector(android.R.color.transparent);
            lv.setAdapter(userAdapter);

            lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {

                    User country = users.get(pos);

                    Intent intent = new Intent(MyActivity.this, ToukouActivity.class);

                    //intent.putExtra("restname", country.getRestname());

                    //intent.putExtra("locality", country.getLocality());

                    startActivity(intent);
                }

            });
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

    public class User {
        private String movie;
        private String picture;
        private String post_id;
        private String user_id;
        private String user_name;
        private String restname;

        public String getMovie() {
            return this.movie;
        }

        public void setMovie(String movie) {
            this.movie = movie;
        }

        public String getPicture() {
            return this.picture;
        }

        public void setPicture(String picture) {
            this.picture = picture;
        }

        public String getPost_id() {
            return this.post_id;
        }

        public void setPost_id(String post_id) {
            this.post_id = post_id;
        }

        public String getUser_id() {
            return this.user_id;
        }

        public void setUser_id(String user_id) {
            this.user_id = user_id;
        }

        public String getUser_name() {
            return this.user_name;
        }

        public void setUser_name(String user_name) {
            this.user_name = user_name;
        }

        public String getRestname() {
            return this.restname;
        }

        public void setRestname(String restname) {
            this.restname = restname;
        }

    }

    public class UserAdapter extends ArrayAdapter<User> {
        private LayoutInflater layoutInflater;


        public UserAdapter(Context context, int viewResourceId, ArrayList<User> users) {
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
            User user = this.getItem(position);

            viewHolder.post_id.setText(user.getPost_id());
            viewHolder.user_id.setText(user.getUser_id());
            viewHolder.user_name.setText(user.getUser_name());
            viewHolder.restname.setText(user.getRestname());
            viewHolder.movie.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    viewHolder.movie.start();
                }
            });
            viewHolder.movie.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                public void onCompletion(MediaPlayer mp) {
                    isMov = false;
                    viewHolder.movie.setVideoURI(null);
                    //動画終了
                }
            });
            //中略
            //ランダムでリソースIDをゲット-rawから取得
            if (!isMov) {
                isMov = true;

                viewHolder.movie.setVideoURI(Uri.parse(user.getMovie()));
                //mVideoView.start(); onPreparedで再生するのでコメント
            }
            try {
                URL url = new URL(user.getPicture());
                InputStream istream = url.openStream();
                Bitmap bitmap = BitmapFactory.decodeStream(istream);
                viewHolder.picture.setImageBitmap(bitmap);
                istream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

            return convertView;
        }


    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.my, menu);
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
        if (id == R.id.action_search__map) {
            Intent intent = new Intent(MyActivity.this, Search_MapActivity.class);
            startActivity(intent);
        }
        return super.onOptionsItemSelected(item);
    }
}
