package com.lukianbat.test.pokeapp.feature.posts.data.repository

import androidx.annotation.MainThread
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.paging.LivePagedListBuilder
import com.lukianbat.test.pokeapp.feature.posts.domain.recycler.boundary.Listing
import com.lukianbat.test.pokeapp.feature.posts.domain.recycler.boundary.NetworkState
import com.lukianbat.test.pokeapp.feature.posts.domain.recycler.boundary.SubredditBoundaryCallback
import com.lukianbat.test.pokeapp.feature.posts.data.datasource.api.PokemonListApiDataSource
import com.lukianbat.test.pokeapp.feature.posts.data.datasource.db.PokemonCacheDataSource
import com.lukianbat.test.pokeapp.feature.posts.domain.model.PokemonCommonResponse
import com.lukianbat.test.pokeapp.feature.posts.domain.model.PokemonDetailNetworkDto
import com.lukianbat.test.pokeapp.feature.posts.domain.model.PokemonDto
import com.lukianbat.test.pokeapp.feature.posts.domain.model.PokemonsListNetworkDto
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import javax.inject.Inject

interface PokemonsRepository {
    fun posts(): Listing<PokemonDto>
}

class PokemonsRepositoryImpl @Inject constructor(
    private val apiDataSource: PokemonListApiDataSource,
    private val cacheDataSource: PokemonCacheDataSource,
    private val pokemonsConverter: PokemonsConverter

) : PokemonsRepository {

    val ioExecutor: ExecutorService = Executors.newSingleThreadExecutor()


    private fun insertResultIntoDb(res: PokemonsListNetworkDto) {
        val commonResponseList = res.results.map {
            apiDataSource.getPokemonDetail(it.name).execute().body() as PokemonDetailNetworkDto
            PokemonCommonResponse
        }
        cacheDataSource.insert(
            pokemonsConverter.convert(res)
        )
    }

    @MainThread
    private fun refresh(): LiveData<NetworkState> {
        val networkState = MutableLiveData<NetworkState>()
        networkState.value = NetworkState.LOADING
        apiDataSource.getPokemonsTop().enqueue(
            object : Callback<PokemonsListNetworkDto> {
               