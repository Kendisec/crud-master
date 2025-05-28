const express = require('express');
require('dotenv').config();
const app = express();
const db = require('./queries.js');

// make the server to parse json data
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.get('/api/movies', (req, res) =>{
    const title = req.query.title;
    if (title) {
    db.getMoviesbyTitle(req, res);
  } else {
    db.getMovies(req, res);
  }
})


app.post('/api/movies', (req, res) =>{
    db.createMovie(req, res);
});

app.get('/api/movies/:id', (req, res) =>{
    db.getMoviebyId(req, res);
}); 

app.delete('/api/movies/:id', (req, res) =>{
    db.deleteMovie(req, res);
});

app.delete('/api/movies', (req, res) =>{
    db.deleteAllMovies(req, res);
});

app.put('/api/movies/:id', (req, res) =>{
    db.updateMovie(req, res);
});

const port = process.env.INVENTORY_PORT;

app.listen(port, () => {
    console.log("listenning on", process.env.MOVIES_DB_HOST, process.env.INVENTORY_PORT);
});