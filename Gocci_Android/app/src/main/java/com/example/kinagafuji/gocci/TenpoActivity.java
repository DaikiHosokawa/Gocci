package com.example.kinagafuji.gocci;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.StrictMode;
import android.support.v4.widget.SwipeRefreshLayout;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
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
import org.w3c.dom.Text;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;


public class TenpoActivity extends Activity {

    private SwipeRefreshLayout mSwipeRefreshLayout;
    private static final String TAG_USER_NAME = "user_name";
    private static final String TAG_PICTURE = "picture";
    private static final String TAG_MOVIE = "movie";
    private static final String TAG_RESTNAME = "restname";
    private static final String TAG_LOCALITY = "locality";
    String restname1;
    String locality1;
    String Url;
    String user_name;
    String picture;
    String movie;
    String restname;
    String locality;


    ProgressDialog pDialog;


    static boolean isXLargeScreen = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_tenpo);


        Intent intent = getIntent();
        restname1 = intent.getStringExtra("restname");
        locality1 = intent.getStringExtra("locality");

        TextView TenpoView = (TextView) findViewById(R.id.TenpoView);
        TenpoView.setText(restname1);
        TextView TenpoView2 = (TextView) findViewById(R.id.TenpoView2);
        TenpoView2.setText(locality1);

        Url = "https://codelecture.com/gocci/submit/restpage.php?restname=" + restname1;

        StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder().detectAll().penaltyLog().build());

        isXLargeScreen = isXLargeScreen();
        // SwipeRefreshLayoutの設定
        mSwipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.refresh);
        mSwipeRefreshLayout.setOnRefreshListener(mOnRefreshListener);
        mSwipeRefreshLayout.setColorSchemeColors(Color.TRANSPARENT, Color.GRAY, Color.TRANSPARENT, Color.TRANSPARENT);

        Button button = (Button) findViewById(R.id.toukoubutton);
        button.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent intent = new Intent(TenpoActivity.this, com.javacv.recorder.FFmpegRecorderActivity.class);
                startActivity(intent);
            }
        });

        new MyTenpoAsync().execute(Url);
        Log.d("URl", Url);
        // Showing progress dialog before sending http request
        pDialog = new ProgressDialog(this);
        pDialog.setMessage("Please wait..");
        pDialog.setIndeterminate(true);
        pDialog.setCancelable(false);
        pDialog.show();


    }


    public class MyTenpoAsync extends AsyncTask<String, String, String> {

        ArrayList<User> users = new ArrayList<User>();
        String data;


        @Override
        protected String doInBackground(String... params) {

            HttpClient httpClient = new DefaultHttpClient();


            StringBuilder uri = new StringBuilder(Url);
            HttpGet request = new HttpGet(uri.toString());
            HttpResponse httpResponse = null;

            try {
                httpResponse = httpClient.execute(request);
            } catch (Exception e) {
                Log.d("JSONSampleActivity", "Error Execute");

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
                }


                try {

                    JSONArray jsonArray = new JSONArray(data);

                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject = jsonArray.getJSONObject(i);

                        user_name = jsonObject.getString(TAG_USER_NAME);
                        picture = jsonObject.getString(TAG_PICTURE);
                        movie = jsonObject.getString(TAG_MOVIE);
                        restname = jsonObject.getString(TAG_RESTNAME);
                        locality = jsonObject.getString(TAG_LOCALITY);

                        Log.d("String", user_name + "/" + picture + "/" + movie + "/" + restname + "/" + locality);

                        User user = new User();

                        //movieとpictureはどうすれば？
                        user.setMovie(movie);
                        user.setPicture(picture);
                        user.setUser_name(user_name);
                        user.setLocality(locality);
                        user.setRestname(restname);

                        users.add(user);


                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Log.d("えらー", String.valueOf(e));
                }


            } else {
                Log.d("JSONSampleActivity", "Status" + status);


            }

            return data;

        }


        // このメソッドは非同期処理の終わった後に呼び出されます
        @Override
        protected void onPostExecute(String data) {

            pDialog.dismiss();

            UserAdapter userAdapter = new UserAdapter(TenpoActivity.this, 0, users);


            ListView lv =
                    (ListView) findViewById(R.id.mylistView3);
            lv.setAdapter(userAdapter);
            lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int pos, long id) {

                    Intent intent = new Intent(TenpoActivity.this, ToukouActivity.class);
                    startActivity(intent);


                }

            });


        }

    }

    public boolean isXLargeScreen() {
        int layout = getResources().getConfiguration().screenLayout;
        return (layout & Configuration.SCREENLAYOUT_SIZE_MASK)
                == Configuration.SCREENLAYOUT_SIZE_XLARGE;
    }


    private static class ViewHolder {
        VideoView movie;
        ImageView picture;
        TextView user_name;
        TextView locality;
        TextView restname;

        public ViewHolder(View view) {
            this.movie = (VideoView) view.findViewById(R.id.movie);
            this.picture = (ImageView) view.findViewById(R.id.picture);
            this.user_name = (TextView) view.findViewById(R.id.user_name);
            this.locality = (TextView) view.findViewById(R.id.locality);
            this.restname = (TextView) view.findViewById(R.id.restname);

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
            ViewHolder viewHolder;

            if (convertView == null) {
                convertView = layoutInflater.inflate(R.layout.list, null);
                viewHolder = new ViewHolder(convertView);
                convertView.setTag(viewHolder);
            } else {
                viewHolder = (ViewHolder) convertView.getTag();
            }

            User user = this.getItem(position);

            viewHolder.user_name.setText(user.getUser_name());
            viewHolder.locality.setText(user.getLocality());
            viewHolder.restname.setText(user.getRestname());
            viewHolder.movie.setVideoURI(Uri.parse(user.getMovie()));
            viewHolder.movie.start();
            try {
                URL url = new URL(user.getPicture());
                InputStream inputStream = url.openStream();
                Drawable drawable = Drawable.createFromStream(inputStream, "webimg");
                inputStream.close();
                viewHolder.picture.setImageDrawable(drawable);


            } catch (Exception e) {
                System.out.println("nuu: " + e);
            }

            /*ImageView userMovie = (ImageView) convertView.findViewById(R.id.movie);
            userMovie.setImageBitmap(user.getMovie());
            ImageView userIcon = (ImageView) convertView.findViewById(R.id.icon);
            userIcon.setImageBitmap(user.getIcon());
            TextView userWord1 = (TextView) convertView.findViewById(R.id.word1);
            userWord1.setText(user.getWord1());
            TextView userWord2 = (TextView) convertView.findViewById(R.id.word2);
            userWord2.setText(user.getWord2());
            TextView userWord3 = (TextView) convertView.findViewById(R.id.word3);
            userWord3.setText(user.getWord3());
            ImageButton userTip = (ImageButton) convertView.findViewById(R.id.tip);
            userTip.setImageBitmap(user.getTip());
            ImageButton userComment = (ImageButton) convertView.findViewById(R.id.comment);
            userComment.setImageBitmap(user.getComment()); */

            return convertView;
        }
    }

    public class User {
        private String movie;
        private String picture;
        private String user_name;
        private String locality;
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

        public String getUser_name() {
            return this.user_name;
        }

        public void setUser_name(String user_name) {
            this.user_name = user_name;
        }

        public String getLocality() {
            return this.locality;
        }

        public void setLocality(String locality) {
            this.locality = locality;
        }

        public String getRestname() {
            return this.restname;
        }

        public void setRestname(String restname) {
            this.restname = restname;
        }


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


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.tenpo, menu);
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
