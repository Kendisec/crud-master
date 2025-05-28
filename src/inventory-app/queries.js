const Pool = require('pg').Pool
require('dotenv').config();
const pool = new Pool({
    user: process.env.MOVIES_DB_USER,
    host: process.env.MOVIES_DB_HOST,
    database: process.env.MOVIES_DB_NAME,
    password: process.env.MOVIES_DB_PASSWORD,
    port: process.env.MOVIES_DB_PORT,
})

const getMovies = (request, response) => {
  pool.query('SELECT * FROM movies ORDER BY id ASC', (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).json(results.rows)
  })
}

const getMoviesbyTitle = (request, response) => {
    const title = request.query.title


  if (!title) {
    return response.status(400).json({ error: 'Missing "title" query parameter' });
  }
    console.log('Title:', title)
    pool.query('SELECT * FROM movies WHERE title = $1', [title], (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).json(results.rows)
  })

    // pool.query(query, values, (error, results) => {
    //     if (error) {
    //         response.status(500).json({error: error.message})
    //         return
    //     }
    //     response.status(200).json(results.rows)
    // })
}

const createMovie = (request, response) => {
    const { title, description } = request.body
    pool.query(
        'INSERT INTO movies (title, description) VALUES ($1, $2) RETURNING *',
        [title, description],
        (error, results) => {
            if (error) {
                response.status(500).json({error: error.message})
                return
            }
            response.status(201).json(results.rows[0])
        }
    )
}



const getMoviebyId = (request, response) => {
  const id = parseInt(request.params.id)
  console.log(id)
  console.log(request.params.id)
  pool.query('SELECT * FROM movies WHERE id = $1', [id], (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).json(results.rows)
  })
}

const deleteMovie = (request, response) => {
  const id = parseInt(request.params.id)

  pool.query('DELETE FROM movies WHERE id = $1', [id], (error, results) => {
    if (error) {
      throw error
    }
    response.status(200).send(`User deleted with ID: ${id}`)
  })
}

const deleteAllMovies = (request, response) => {
    pool.query('DELETE FROM movies', (error, results) => {
        if (error) {
            response.status(500).json({error: error.message})
            return
        }
        response.status(200).json({message: 'All movies deleted successfully'})
    })
}



// must be review
const updateMovie = (request, response) => {
  console.log('BODY:', request.body); // Debug line
  const id = parseInt(request.params.id)
  const { title, description } = request.body

  pool.query(
    'UPDATE movies SET title = $1, description = $2 WHERE id = $3',
    [title, description, id],
    (error, results) => {
      if (error) {
        throw error
      }
      response.status(200).send(`User modified with ID: ${id}`)
    }
  )
}

module.exports = {
    getMovies,
    getMoviebyId,
    deleteMovie,
    updateMovie,
    getMoviesbyTitle,
    createMovie,
    deleteAllMovies,
}